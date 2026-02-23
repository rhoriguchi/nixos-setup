{
  config,
  interfaces,
  lib,
  pkgs,
  secrets,
  ...
}:
let
  internalInterface = interfaces.internal;
  internalInterfaces = lib.filter (interface: lib.hasPrefix internalInterface interface) (
    lib.attrNames config.networking.interfaces
  );

  ips = import (lib.custom.relativeToRoot "configuration/devices/headless/urahara/dhcp/ips.nix");

  rootDir = "/var/lib/named";

  reverseZones = map (
    subnet:
    let
      parts = lib.splitString "/" subnet.subnet;
      ip = lib.elemAt parts 0;
      prefix = lib.elemAt parts 1;

      octets = lib.splitString "." ip;
      octetCount = (lib.toInt prefix) / 8;

      relevant = lib.sublist 0 octetCount octets;
      reversed = lib.reverseList relevant;
    in
    "${lib.concatStringsSep "." reversed}.in-addr.arpa"
  ) config.services.kea.dhcp4.settings.subnet4;

  zones = [ "local" ] ++ reverseZones;

  baseZone =
    let
      ttl = config.services.kea.dhcp4.settings.valid-lifetime;
    in
    {
      TTL = ttl;

      SOA = {
        serial = 1;

        nameServer = "${config.networking.hostName}.local.";
        adminEmail = config.security.acme.defaults.email;

        refresh = ttl;
        retry = ttl / 10;
        expire = ttl * 24 * 7;
        minimum = ttl;
      };

      NS = [
        "${config.networking.hostName}.local."
      ];
    };

  zoneFiles = {
    "local" = pkgs.writeText "local.zone" (
      lib.dns.toString "local" (
        baseZone
        // {
          subdomains = {
            "${config.networking.hostName}".A = [ ips.urahara ];
            "unifi".A = [ ips.cloudKey ];
          };
        }
      )
    );
  }
  // lib.listToAttrs (
    map (
      zone: lib.nameValuePair zone (pkgs.writeText "${zone}.zone" (lib.dns.toString zone baseZone))
    ) reverseZones
  );
in
{
  imports = [ ./adguardhome.nix ];

  networking = {
    nameservers = [ "127.0.0.1" ];

    firewall.interfaces = lib.listToAttrs (
      map (
        interface:
        lib.nameValuePair interface {
          allowedUDPPorts = [
            53 # DNS
          ];

          allowedTCPPorts = [
            53 # DNS
          ];
        }
      ) internalInterfaces
    );
  };

  systemd.tmpfiles.rules = [
    "d ${rootDir} 0750 named named"
  ]
  ++ lib.mapAttrsToList (
    key: value: "C ${rootDir}/${key}.zone 0640 named named - ${value}"
  ) zoneFiles;

  services = {
    nginx.stream.resolvers = [ "127.0.0.1" ];

    bind = {
      enable = true;

      forward = "first";
      forwarders = [
        "1.1.1.1 port 853 tls cloudflare-tls"
        "8.8.8.8 port 853 tls google-tls"
        "9.9.9.9 port 853 tls quad9-tls"
      ];

      cacheNetworks = [
        "localhost"
        "localnets"
      ];

      zones = lib.listToAttrs (
        map (
          zone:
          lib.nameValuePair zone {
            master = true;
            file = "${rootDir}/${zone}.zone";
            extraConfig = ''
              allow-update {
                key tsig-key;
              };

              zone-statistics yes;
            '';
          }
        ) zones
      );

      extraConfig = ''
        tls cloudflare-tls {
          ca-file "/etc/ssl/certs/ca-certificates.crt";
          remote-hostname "cloudflare-dns.com";
        };

        tls google-tls {
          ca-file "/etc/ssl/certs/ca-certificates.crt";
          remote-hostname "dns.google";
        };

        tls quad9-tls {
          ca-file "/etc/ssl/certs/ca-certificates.crt";
          remote-hostname "dns.quad9.net";
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

          tsig-keys = [
            {
              name = "tsig-key";
              algorithm = "hmac-sha256";
              secret = secrets.kea.ddnsKey;
            }
          ];

          forward-ddns.ddns-domains = [
            {
              name = "local.";
              key-name = "tsig-key";
              dns-servers = [
                {
                  ip-address = "127.0.0.1";
                  port = config.services.bind.listenOnPort;
                }
              ];
            }
          ];

          reverse-ddns.ddns-domains = map (reverseZone: {
            name = "${reverseZone}.";
            key-name = "tsig-key";
            dns-servers = [
              {
                ip-address = "127.0.0.1";
                port = config.services.bind.listenOnPort;
              }
            ];
          }) reverseZones;
        };
      };
    };
  };
}
