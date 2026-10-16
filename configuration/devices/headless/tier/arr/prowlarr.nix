{
  config,
  lib,
  ...
}:
let
  apps = [
    {
      service = "radarr";
      type = "anime";
    }
    {
      service = "radarr";
      type = "movies";
    }
    {
      service = "sonarr";
      type = "anime";
    }
    {
      service = "sonarr";
      type = "series";
    }
  ];

  containerName = app: "${app.service}-${app.type}";
in
{
  sops = {
    secrets = {
      "prowlarr+services/prowlarr/apiKey" = {
        key = "services/prowlarr/apiKey";

        restartUnits = [
          config.systemd.services.prowlarr.name
          config.systemd.services."prometheus-exportarr-prowlarr-exporter".name
        ];
      };

      "declarr+services/prowlarr/apiKey" = {
        key = "services/prowlarr/apiKey";

        owner = config.services.declarr.user;
        restartUnits = [ config.systemd.services.declarr.name ];
      };
    };

    templates."services.prowlarr.environmentFile" = {
      content = ''
        PROWLARR__AUTH__APIKEY=${config.sops.placeholder."prowlarr+services/prowlarr/apiKey"}
      '';

      restartUnits = [ config.systemd.services.prowlarr.name ];
    };
  };

  services = {
    prowlarr = {
      enable = true;

      # https://wiki.servarr.com/prowlarr/environment-variables
      settings = {
        server.allowedhosts = lib.concatStringsSep "," (
          [
            "prowlarr.00a.ch"

            "127.0.0.1"
          ]
          ++ lib.unique [
            config.containers.radarr-anime.hostAddress
            config.containers.radarr-movies.hostAddress
            config.containers.sonarr-anime.hostAddress
            config.containers.sonarr-series.hostAddress
          ]
        );

        auth = {
          method = "Forms";
          required = "DisabledForLocalAddresses";
        };
      };

      environmentFiles = [ config.sops.templates."services.prowlarr.environmentFile".path ];
    };

    prometheus.exporters.exportarr-prowlarr.apiKeyFile =
      config.sops.secrets."prowlarr+services/prowlarr/apiKey".path;

    declarr.config.prowlarr = {
      declarr = {
        type = "prowlarr";
        url = "http://127.0.0.1:${toString config.services.prowlarr.settings.server.port}";
      };

      config.host.apiKey = config.sops.secrets."declarr+services/prowlarr/apiKey".path;

      applications = lib.listToAttrs (
        map (
          app:
          let
            container = config.containers.${containerName app};
          in
          lib.nameValuePair "${lib.toSentenceCase app.service} ${app.type}" {
            implementation = lib.toSentenceCase app.service;
            syncLevel = "fullSync";
            tags = [ app.type ];

            fields = {
              apiKey = config.sops.secrets."declarr+services/${app.service}/apiKey".path;
              baseUrl = "http://${container.localAddress}:${
                toString container.config.services.${app.service}.settings.server.port
              }/${app.type}";
              prowlarrUrl = "http://${container.hostAddress}:${toString config.services.prowlarr.settings.server.port}";
            };
          }
        ) apps
      );

      indexerProxy.FlareSolverr = {
        implementation = "FlareSolverr";
        tags = [ "flaresolverr" ];

        fields.host = "http://127.0.0.1:${toString config.services.flaresolverr.port}";
      };

      indexer = {
        "The Pirate Bay" = {
          indexerName = "The Pirate Bay";
          priority = 1;
          tags = [
            "series"
            "movies"
          ];
        };

        "Nyaa.si" = {
          indexerName = "Nyaa.si";
          priority = 1;
          tags = [ "anime" ];
        };

        # TODO uncomment when FlareSolverr can solve the bot protection again
        # "1337x" = {
        #   indexerName = "1337x";
        #   priority = 10;
        #   tags = [
        #     "flaresolverr"
        #     "series"
        #     "movies"
        #   ];
        # };
        #
        # EZTV = {
        #   indexerName = "EZTV";
        #   priority = 10;
        #   tags = [
        #     "flaresolverr"
        #     "series"
        #   ];
        # };
      };
    };

    flaresolverr = {
      enable = true;
      prometheusExporter.enable = true;
    };

    infomaniak = {
      enable = true;

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
            include /run/nginx-authelia/auth.conf;

            proxy_buffering off;

            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $host;
            proxy_set_header X-Forwarded-Server $host;
          '';
        };
      };
    };
  };

  systemd.services.declarr =
    let
      requiredUnits = [
        config.systemd.services.prowlarr.name
        "${config.virtualisation.oci-containers.containers.flaresolverr.serviceName}.service"
      ]
      ++ map (app: config.systemd.services."container@${containerName app}".name) apps;
    in
    {
      wants = requiredUnits;
      after = requiredUnits;
    };
}
