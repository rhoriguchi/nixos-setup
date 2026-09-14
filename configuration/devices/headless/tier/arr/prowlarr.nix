{
  config,
  lib,
  secrets,
  ...
}:
{
  sops = {
    secrets."services/prowlarr/apiKey" = { };

    templates."services.prowlarr.environmentFile" = {
      content = ''
        PROWLARR__AUTH__APIKEY=${config.sops.placeholder."services/prowlarr/apiKey"}
      '';

      restartUnits = [ config.systemd.services.prowlarr.name ];
    };
  };

  services = {
    prowlarr = {
      enable = true;

      # https://wiki.servarr.com/prowlarr/environment-variables
      settings.auth = {
        method = "Forms";
        required = "DisabledForLocalAddresses";
      };

      environmentFiles = [ config.sops.templates."services.prowlarr.environmentFile".path ];
    };

    prometheus.exporters.exportarr-prowlarr = lib.mkForce {
      enable = true;

      port = 9710;

      url = "http://127.0.0.1:${toString config.services.prowlarr.settings.server.port}";

      apiKeyFile = config.sops.secrets."services/prowlarr/apiKey".path;

      environment = {
        INTERFACE = "127.0.0.1";

        PROWLARR__BACKFILL = "true";
      };
    };

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
        acmeRoot = null;
        forceSSL = true;

        extraConfig = ''
          include /run/nginx-authelia/location.conf;
        '';

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.prowlarr.settings.server.port}";

          proxyWebsockets = true;
          recommendedProxySettings = false;

          extraConfig = ''
            include /run/nginx-authelia/auth.conf;

            proxy_buffering off;

            proxy_set_header Host $host;
            proxy_set_header X-Real-IP 127.0.0.1;
            proxy_set_header X-Forwarded-For 127.0.0.1;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $host;
            proxy_set_header X-Forwarded-Server $host;
          '';
        };
      };
    };
  };
}
