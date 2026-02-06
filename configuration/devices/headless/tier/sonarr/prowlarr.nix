{ config, secrets, ... }:
{
  services = {
    prowlarr = {
      enable = true;

      # https://wiki.servarr.com/prowlarr/environment-variables
      settings.auth = {
        method = "Forms";
        required = "DisabledForLocalAddresses";
      };
    };

    prometheus.exporters.exportarr-prowlarr.environment.API_KEY = secrets.prowlarr.apiKey;

    flaresolverr = {
      enable = true;
      prometheusExporter.enable = true;
    };

    infomaniak = {
      enable = true;

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
      hostnames = [ "prowlarr.00a.ch" ];
    };

    nginx = {
      enable = true;

      virtualHosts."prowlarr.00a.ch" = {
        enableACME = true;
        forceSSL = true;

        extraConfig = ''
          include /run/nginx-authelia/location.conf;
        '';

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.prowlarr.settings.server.port}";

          proxyWebsockets = true;
          recommendedProxySettings = false;

          extraConfig = ''
            proxy_buffering off;

            proxy_set_header Host $host;
            proxy_set_header X-Real-IP 127.0.0.1;
            proxy_set_header X-Forwarded-For 127.0.0.1;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $host;
            proxy_set_header X-Forwarded-Server $host;

            include /run/nginx-authelia/auth.conf;

            satisfy any;
            allow 192.168.2.0/24;
            deny all;
          '';
        };
      };
    };
  };
}
