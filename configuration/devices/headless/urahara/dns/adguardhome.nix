{
  config,
  lib,
  pkgs,
  secrets,
  ...
}:
{
  services = {
    bind = {
      listenOn = lib.mkForce [ "127.0.0.1" ];
      listenOnPort = 9053;

      listenOnIpv6 = lib.mkForce [ "::1" ];
      listenOnIpv6Port = 9053;
    };

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

        extraConfig = ''
          include /run/nginx-authelia/location.conf;
        '';

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.adguardhome.port}";

          proxyWebsockets = true;

          extraConfig = ''
            proxy_buffering off;

            include /run/nginx-authelia/auth.conf;
          '';
        };
      };
    };

    adguardhome = {
      enable = true;

      host = "127.0.0.1";

      mutableSettings = false;
      settings =
        assert pkgs.adguardhome.schema_version == 32;
        {
          dns = rec {
            bootstrap_dns = [ "127.0.0.1:${toString config.services.bind.listenOnPort}" ];
            upstream_dns = bootstrap_dns;

            local_ptr_upstreams = [ "127.0.0.1:${toString config.services.bind.listenOnPort}" ];

            cache_enabled = false;
            cache_optimistic = false;
            ratelimit = 0;
          };

          filtering.rewrites =
            (map (domain: {
              inherit domain;
              answer = "${config.networking.hostName}.local";
              enabled = true;
            }) config.services.infomaniak.hostnames)
            ++ (map
              (domain: {
                inherit domain;
                answer = "XXLPitu-Ulquiorra.local";
                enabled = true;
              })
              [
                "printer.00a.ch"
                "scanner.00a.ch"
              ]
            )
            ++ (map
              (domain: {
                inherit domain;
                answer = "XXLPitu-Tier.local";
                enabled = true;
              })
              [
                "authelia.00a.ch"
                "deluge.00a.ch"
                "grafana.00a.ch"
                "home-assistant.00a.ch"
                "minecraft.00a.ch"
                "monitoring.00a.ch"
                "prometheus.00a.ch"
                "prowlarr.00a.ch"
                "rustdesk.00a.ch"
                "sonarr.00a.ch"
                "tautulli.00a.ch"
              ]
            );
        };
    };
  };
}
