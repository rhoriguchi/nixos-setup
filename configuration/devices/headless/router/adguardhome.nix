{ config, interfaces, lib, pkgs, secrets, ... }:
let
  internalInterface = interfaces.internal;

  cloudKeyIp = "192.168.1.2";
  wingoRouterIp = "192.168.0.254";
  routerIp = "192.168.1.1";

  dnsmasqPort = config.services.dnsmasq.settings.port;

  bootstrapDns = [ "tls://1.1.1.1" "tls://1.0.0.1" ];
in {
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
      "${internalInterface}.1" = rules;
      "${internalInterface}.2" = rules;
      "${internalInterface}.3" = rules;
      "${internalInterface}.100" = rules;
    };
  };

  services = {
    infomaniak = {
      enable = true;

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
      hostnames = [ "adguardhome.00a.ch" ];
    };

    nginx = {
      enable = true;

      virtualHosts."adguardhome.00a.ch" = {
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.adguardhome.port}";
          proxyWebsockets = true;
          basicAuth = secrets.nginx.basicAuth."adguardhome.00a.ch";

          extraConfig = ''
            proxy_buffering off;

            satisfy any;

            allow 192.168.1.0/24;
            deny all;
          '';
        };
      };
    };

    dnsmasq.resolveLocalQueries = false;

    lancache.upstreamDns = map (dns: lib.replaceStrings [ "tls://" ] [ "" ] dns) bootstrapDns;

    adguardhome = {
      enable = true;

      host = "127.0.0.1";

      mutableSettings = false;
      settings = assert pkgs.adguardhome.schema_version == 29; {
        dns = {
          bootstrap_dns = bootstrapDns;
          upstream_dns = bootstrapDns ++ [ "[/local/]127.0.0.1:${toString dnsmasqPort}" ];

          local_ptr_upstreams = [ "127.0.0.1:${toString dnsmasqPort}" ];

          ratelimit = 0;
        };

        clients.persistent = [
          {
            name = "Private VLAN";
            ids = [ "192.168.1.0/24" ];
            use_global_settings = true;
            use_global_blocked_services = true;
          }
          {
            name = "DMZ VLAN";
            ids = [ "192.168.2.0/24" ];
            use_global_settings = true;
            filtering_enabled = false;
          }
          {
            name = "IoT VLAN";
            ids = [ "192.168.3.0/24" ];
            filtering_enabled = false;
          }
          {
            name = "Guest VLAN";
            ids = [ "192.168.100.0/24" ];
            use_global_settings = true;
            use_global_blocked_services = true;
            upstreams = [ "tls://1.1.1.1" "tls://1.0.0.1" ];
          }
        ];

        filtering.rewrites = [
          {
            domain = "unifi.local";
            answer = cloudKeyIp;
          }
          {
            domain = "winbox.local";
            answer = wingoRouterIp;
          }
          {
            domain = "${config.networking.hostName}.local";
            answer = routerIp;
          }
        ] ++ (map (domain: {
          inherit domain;
          # TODO uncomment when https://github.com/AdguardTeam/AdGuardHome/issues/7327 fixed
          # answer = "${config.networking.hostName}.local";
          answer = routerIp;
        }) config.services.infomaniak.hostnames) ++ (map (domain: {
          inherit domain;
          answer = "XXLPitu-Ulquiorra.local";
        }) [ "printer.00a.ch" "scanner.00a.ch" ]) ++ (map (domain: {
          inherit domain;
          answer = "XXLPitu-Server.local";
        }) [
          "deluge.00a.ch"
          "esphome.00a.ch"
          "grafana.00a.ch"
          "home-assistant.00a.ch"
          "immich.00a.ch"
          "monitoring.00a.ch"
          "prometheus.00a.ch"
          "prowlarr.00a.ch"
          "pushgateway.00a.ch"
          "sonarr.00a.ch"
          "tautulli.00a.ch"
        ]) ++ lib.optionals config.services.lancache.enable (map (cachedDomain: {
          domain = lib.replaceStrings [ "*." ] [ "" ] cachedDomain;
          # TODO uncomment when https://github.com/AdguardTeam/AdGuardHome/issues/7327 fixed
          # answer = "${config.networking.hostName}.local";
          answer = routerIp;
        }) config.services.lancache.cacheDomains);
      };
    };
  };
}
