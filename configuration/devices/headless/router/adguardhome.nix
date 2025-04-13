{ config, interfaces, lib, pkgs, secrets, ... }:
let
  internalInterface = interfaces.internal;

  ips = import (lib.custom.relativeToRoot "configuration/devices/headless/router/dhcp/ips.nix");

  dnsmasqPort = 9053;

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

      "${internalInterface}.2" = rules;
      "${internalInterface}.3" = rules;
      "${internalInterface}.10" = rules;
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

            allow 192.168.2.0/24;
            deny all;
          '';
        };
      };

      stream.resolvers = [ "127.0.0.1" ];
    };

    dnsmasq = {
      settings.port = dnsmasqPort;
      resolveLocalQueries = false;
    };

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

        filtering.rewrites = [
          {
            domain = "unifi.local";
            answer = ips.cloudKey;
          }
          {
            domain = "winbox.local";
            answer = ips.wingoRouter;
          }
          {
            domain = "${config.networking.hostName}.local";
            answer = ips.router;
          }
        ] ++ (map (domain: {
          inherit domain;
          # TODO uncomment when https://github.com/AdguardTeam/AdGuardHome/issues/7327 fixed
          # answer = "${config.networking.hostName}.local";
          answer = ips.router;
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
          "minecraft.00a.ch"
          "monitoring.00a.ch"
          "plex.00a.ch"
          "prometheus.00a.ch"
          "prowlarr.00a.ch"
          "pushgateway.00a.ch"
          "sonarr.00a.ch"
          "tautulli.00a.ch"
        ]) ++ lib.optionals config.services.lancache.enable (map (cachedDomain: {
          domain = cachedDomain;
          # TODO uncomment when https://github.com/AdguardTeam/AdGuardHome/issues/7327 fixed
          # answer = "${config.networking.hostName}.local";
          answer = ips.router;
        }) config.services.lancache.cacheDomains);
      };
    };
  };
}
