{
  config,
  interfaces,
  lib,
  libCustom,
  libDns,
  pkgs,
  secrets,
  ...
}:
let
  internalInterface = interfaces.internal;
  internalInterfaces = lib.filter (interface: lib.hasPrefix internalInterface interface) (
    lib.attrNames config.networking.interfaces
  );

  ips = import (libCustom.relativeToRoot "configuration/devices/headless/urahara/dhcp/ips.nix");

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

  ddnsZones = [ "local" ] ++ reverseZones;

  ddnsZone =
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

  rpzZone = ddnsZone // {
    TTL = 60;

    SOA = ddnsZone.SOA // {
      refresh = 60 * 60;
      retry = 60 * 15;
      expire = 60 * 60 * 14;
      minimum = 60;
    };
  };

  zoneFiles = {
    "local" = pkgs.writeText "local.zone" (
      libDns.toString "local" (
        ddnsZone
        // {
          subdomains = {
            "${config.networking.hostName}".A = [ ips.urahara ];
            "unifi".A = [ ips.cloudKey ];
          };
        }
      )
    );

    "rpz.00a.ch" =
      let
        cnames =
          answer: domains:
          lib.listToAttrs (
            map (
              domain:
              lib.nameValuePair domain {
                CNAME = [ "${answer}." ];
              }
            ) domains
          );
      in
      pkgs.writeText "rpz.00a.ch.zone" (
        libDns.toString "rpz.00a.ch" (
          rpzZone
          // {
            subdomains =
              (cnames "${config.networking.hostName}.local" config.services.infomaniak.hostnames)
              // (cnames "XXLPitu-Ulquiorra.local" [
                "printer.00a.ch"
                "scanner.00a.ch"
              ])
              // (cnames "XXLPitu-Tier.local" [
                "authelia.00a.ch"
                "bazarr.00a.ch"
                "deluge.00a.ch"
                "grafana.00a.ch"
                "home-assistant.00a.ch"
                "jellyfin.00a.ch"
                "minecraft.00a.ch"
                "monitoring.00a.ch"
                "prometheus.00a.ch"
                "prowlarr.00a.ch"
                "rustdesk.00a.ch"
                "sonarr.00a.ch"
                "tautulli.00a.ch"
              ]);
          }
        )
      );
  }
  // lib.listToAttrs (
    map (
      zone: lib.nameValuePair zone (pkgs.writeText "${zone}.zone" (libDns.toString zone ddnsZone))
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

  systemd = {
    tmpfiles.rules = [
      "d ${rootDir} 0750 named named"
      "L+ ${rootDir}/rpz.00a.ch.zone - - - - ${zoneFiles."rpz.00a.ch"}"
    ]
    ++ map (zone: "C ${rootDir}/${zone}.zone 0640 named named - ${zoneFiles.${zone}}") ddnsZones;

    services.bind.restartTriggers = lib.attrValues (
      lib.filterAttrs (key: _: !(lib.elem key ddnsZones)) zoneFiles
    );
  };

  services = {
    nginx.stream.resolvers = [ "127.0.0.1" ];

    bind = {
      enable = true;

      # Fails with `loading from master file /var/lib/named/*.zone failed: file not found`
      checkConfig = false;

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

      zones = lib.mapAttrs (key: _: {
        master = true;
        file = "${rootDir}/${key}.zone";
        extraConfig = ''
          zone-statistics yes;

          ${lib.optionalString (lib.elem key ddnsZones) ''
            allow-update {
              key tsig-key;
            };
          ''}
        '';
      }) zoneFiles;

      extraOptions = ''
        response-policy {
          zone "rpz.00a.ch";
        };
      '';

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

        logging {
          category rpz { null; };
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
