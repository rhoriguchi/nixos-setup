{ secrets, interfaces, ... }:
let
  internalInterface = interfaces.internal;

  ips = import (lib.custom.relativeToRoot "configuration/devices/headless/router/dhcp/ips.nix");

  dnsZoneDir = "/var/lib/named";
  localZoneFile = "${dnsZoneDir}/local.zone";

  mkZoneFile = let ttl = 60 * 5;
  in data:
  pkgs.writeText data.hostname ''
    $TTL ${toString (ttl * 24)}
    @ IN SOA ${config.networking.hostName}.local. ${lib.replaceStrings [ "@" ] [ "." ] config.security.acme.defaults.email}. (${
      lib.concatSTringsSep " " [
        "1" # Serial
        (toString ttl) # Refresh
        (toString (ttl / 2)) # Retry
        (toString (ttl * 24 * 7)) # Expire
        (toString (ttl * 24)) # Minimum TTL
      ]
    })

      IN NS ${config.networking.hostName}.local.

    ${if lib.hasAttr "ip" data then "@ IN A ${data.ip}" else "@ IN CNAME ${data.hostname}"}
  '';
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

  system.activationScripts.bind = ''
    mkdir -p ${dnsZoneDir}
    touch ${localZoneFile}
    chown -R named:named ${dnsZoneDir}
  '';

  services = {
    nginx.stream.resolvers = [ "127.0.0.1" ];

    bind = {
      enable = true;

      forward = "only";
      forwarders = [ "1.1.1.1 port 853 tls cloudflare_tls" "1.0.0.1 port 853 tls cloudflare_tls" ];

      cacheNetworks = [ "localhost" "localnets" ];

      zones = {
        "local" = {
          master = true;
          file = localZoneFile;
          extraConfig = ''
            zone-statistics yes;

            allow-update { key "tsig-key"; };
          '';
        };

        "${config.networking.hostName}.local" = {
          master = true;
          file = mkZoneFile {
            hostname = "${config.networking.hostName}.local";
            ip = ips.router;
          };
          extraConfig = ''
            zone-statistics yes;
          '';
        };
      };

      # TODO BIND commented
      # reverse = {};

      extraConfig = ''
        tls cloudflare_tls {
          ca-file "/etc/ssl/certs/ca-certificates.crt";
          remote-hostname "cloudflare-dns.com";
        };

        key "tsig-key" {
          algorithm hmac-sha256;
          secret "${secrets.kea.ddnsKey}";
        };

        logging {
          channel update_debug {
            file "/run/named/update.log";
            severity debug 3;
            print-time yes;
            print-severity yes;
            print-category yes;
          };

          category update {
            update_debug;
          };

          category update-security {
            update_debug;
          };

          category general {
            update_debug;
          };
        };
      '';
    };

    kea.dhcp-ddns = {
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
          dns-servers = [{ ip-address = "127.0.0.1"; }];
        }];

        # TODO BIND commented
        # reverse-ddns.ddns-domains = [ ];
      };
    };
  };
}
