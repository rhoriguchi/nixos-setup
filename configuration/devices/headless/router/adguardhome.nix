{ pkgs, config, interfaces, secrets, ... }:
let
  internalInterface = interfaces.internal;

  routerIp = "192.168.1.1";
  serverIp = "192.168.2.2";

  dnsmasqPort = config.services.dnsmasq.settings.port;
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
            satisfy any;

            allow 192.168.1.0/24;
            deny all;
          '';
        };
      };
    };

    dnsmasq.resolveLocalQueries = false;

    adguardhome = {
      enable = true;

      host = "127.0.0.1";

      mutableSettings = false;
      settings = assert pkgs.adguardhome.schema_version == 28; {
        dns = rec {
          bootstrap_dns = [ "tls://1.1.1.1" "tls://1.0.0.1" ];
          upstream_dns = bootstrap_dns ++ [ "[/local/]127.0.0.1:${toString dnsmasqPort}" ];

          local_ptr_upstreams = [ "127.0.0.1:${toString dnsmasqPort}" ];

          ratelimit = 0;
        };

        filtering.rewrites = (map (domain: {
          inherit domain;
          answer = routerIp;
          # TODO remove "${config.networking.hostName}.local" domain rewrite
        }) [ "${config.networking.hostName}.local" "adguardhome.00a.ch" "wireguard.00a.ch" ]) ++ (map (domain: {
          inherit domain;
          answer = serverIp;
        }) [
          "deluge.00a.ch"
          "esphome.00a.ch"
          "home-assistant.00a.ch"
          "monitoring.00a.ch"
          "prowlarr.00a.ch"
          "sonarr.00a.ch"
          "tautulli.00a.ch"
        ]);
      };
    };
  };
}
