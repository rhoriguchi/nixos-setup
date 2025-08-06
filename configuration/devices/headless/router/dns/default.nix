{ config, interfaces, lib, pkgs, secrets, ... }:
let
  internalInterface = interfaces.internal;

  ips = import (lib.custom.relativeToRoot "configuration/devices/headless/router/dhcp/ips.nix");

  dnsZoneDir = "/var/lib/named";

  localARecords = {
    "${config.networking.hostName}" = ips.router;

    "unifi" = ips.cloudKey;
  };

  reverseZones =
    [ "1.168.192.in-addr.arpa" "2.168.192.in-addr.arpa" "3.168.192.in-addr.arpa" "10.168.192.in-addr.arpa" "100.168.192.in-addr.arpa" ];

  zoneHeader = let ttl = config.services.kea.dhcp4.settings.valid-lifetime;
  in ''
    $TTL ${toString ttl}
    @ IN SOA ${config.networking.hostName}.local. ${lib.replaceStrings [ "@" ] [ "." ] config.security.acme.defaults.email}. (${
      lib.concatStringsSep " " [
        "1" # Serial
        (toString ttl) # Refresh
        (toString (ttl / 10)) # Retry
        (toString (ttl * 24 * 7)) # Expire
        (toString ttl) # Minimum TTL
      ]
    })

      IN NS ${config.networking.hostName}.local.
  '';

  zoneFiles = {
    "${dnsZoneDir}/local.zone" = pkgs.writeText "local.zone" ''
      ${zoneHeader}

      ${lib.concatStringsSep "\n" (lib.mapAttrsToList (domain: ip: "${domain}.local. A ${ip}") localARecords)}
    '';
  } // lib.listToAttrs (map (zone: lib.nameValuePair "${dnsZoneDir}/${zone}.zone" (pkgs.writeText "${zone}.zone" zoneHeader)) reverseZones);

  addStatisticsToZones = zones:
    lib.mapAttrs (_: value:
      value // {
        extraConfig = value.extraConfig or "" + ''
          zone-statistics yes;
        '';
      }) zones;
in {
  imports = [ ./adguardhome.nix ];

  networking = {
    nameservers = [ "127.0.0.1" ];

    firewall.interfaces = let
      rules = {
        allowedUDPPorts = [
          53 # DNS
        ];

        allowedTCPPorts = [
          53 # DNS
        ];
      };
    in {
      "${internalInterface}" = rules;

      "${internalInterface}.2" = rules;
      "${internalInterface}.3" = rules;
      "${internalInterface}.10" = rules;
      "${internalInterface}.100" = rules;
    };
  };

  # TODO figure out how to replace zone file if static ip gets added or removed
  system.activationScripts.bind = ''
    mkdir -p ${dnsZoneDir}

    ${lib.concatStringsSep "\n" (lib.mapAttrsToList (zoneFile: templateFile: ''
      if [ ! -f "${zoneFile}" ]; then
        cat ${templateFile} > "${zoneFile}"
      fi
    '') zoneFiles)}

    chown -R named:named ${dnsZoneDir}
  '';

  systemd.services.bind.restartTriggers = lib.unique (lib.attrValues zoneFiles);

  services = {
    nginx.stream.resolvers = [ "127.0.0.1" ];

    bind = {
      enable = true;

      forward = "first";
      forwarders = [ "1.1.1.1 port 853 tls cloudflare-tls" "1.0.0.1 port 853 tls cloudflare-tls" ];

      cacheNetworks = [ "localhost" "localnets" ];

      zones = addStatisticsToZones ({
        local = {
          master = true;
          file = "${dnsZoneDir}/local.zone";
          extraConfig = ''
            allow-update { key tsig-key; };
          '';
        };
      } // lib.listToAttrs (map (zone:
        lib.nameValuePair zone {
          master = true;
          file = "${dnsZoneDir}/${zone}.zone";
          extraConfig = ''
            allow-update { key tsig-key; };
          '';
        }) reverseZones));

      extraConfig = ''
        tls cloudflare-tls {
          ca-file "/etc/ssl/certs/ca-certificates.crt";
          remote-hostname "cloudflare-dns.com";
        };

        key tsig-key {
          algorithm hmac-sha256;
          secret "${secrets.kea.ddnsKey}";
        };
      '';
    };

    kea = {
      dhcp4.settings = {
        dhcp-ddns.enable-updates = true;

        ddns-override-client-update = true;
        ddns-replace-client-name = "when-not-present";
        ddns-update-on-renew = true;
      };

      dhcp-ddns = {
        enable = true;

        settings = {
          ip-address = "127.0.0.1";
          port = 53001;

          ncr-format = "JSON";
          ncr-protocol = "UDP";

          tsig-keys = [{
            name = "tsig-key";
            algorithm = "hmac-sha256";
            secret = secrets.kea.ddnsKey;
          }];

          forward-ddns.ddns-domains = [{
            name = "local.";
            key-name = "tsig-key";
            dns-servers = [{
              ip-address = "127.0.0.1";
              port = config.services.bind.listenOnPort;
            }];
          }];

          reverse-ddns.ddns-domains = map (reverseZone: {
            name = "${reverseZone}.";
            key-name = "tsig-key";
            dns-servers = [{
              ip-address = "127.0.0.1";
              port = config.services.bind.listenOnPort;
            }];
          }) reverseZones;
        };
      };
    };
  };
}
