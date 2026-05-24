{
  config,
  lib,
  pkgs,
  secrets,
  ...
}:
let
  rootBindmountDir = "/mnt/bindmount/radarr";
  bindmountDir = "${rootBindmountDir}/disk-Movies";

  getContainerCfg = type: config.containers."radarr-${type}".config;

  createContainer =
    type:
    let
      containerCfg = getContainerCfg type;
    in
    {
      autoStart = true;
      ephemeral = true;

      privateNetwork = true;
      hostAddress = "169.254.1.1";
      localAddress =
        {
          anime = "169.254.1.145";
          movies = "169.254.1.20";
        }
        .${type};

      bindMounts = {
        "${containerCfg.services.radarr.dataDir}" = {
          isReadOnly = false;
          hostPath = "/var/lib/radarr-${type}";
        };

        "${bindmountDir}" = {
          isReadOnly = false;
          hostPath = bindmountDir;
        };

        "/mnt/Data/Deluge" = {
          isReadOnly = false;
          hostPath = "/mnt/Data/Deluge";
        };
      };

      config = {
        nixpkgs.pkgs = pkgs;
        system.stateVersion = config.system.stateVersion;

        users = {
          users = {
            "${config.services.radarr.user}".extraGroups = [ config.services.deluge.group ];

            "${config.services.deluge.user}" = {
              group = config.services.deluge.group;
              uid = config.ids.uids.deluge;
              home = config.services.deluge.dataDir;
            };
          };

          groups.${config.services.deluge.group}.gid = config.ids.gids.deluge;
        };

        services = {
          radarr = {
            enable = true;

            openFirewall = true;

            # https://wiki.servarr.com/radarr/environment-variables
            settings = {
              app.instancename = "Radarr ${lib.toSentenceCase type}";

              server.urlbase = "/${type}";

              auth = {
                apikey = secrets.radarr.apiKey;
                method = "Forms";
                required = "DisabledForLocalAddresses";
              };
            };
          };

          prometheus.exporters.exportarr-radarr = {
            enable = true;

            openFirewall = true;

            url = "http://127.0.0.1:${toString containerCfg.services.radarr.settings.server.port}/${type}";

            environment.API_KEY = containerCfg.services.radarr.settings.auth.apikey;
          };
        };

        systemd.services.radarr.serviceConfig.PrivateUsers = lib.mkForce false;
      };
    };

  createNginxVirtualHostLocation =
    type:
    let
      containerCfg = getContainerCfg type;
    in
    {
      proxyPass = "http://${
        config.containers."radarr-${type}".localAddress
      }:${toString containerCfg.services.radarr.settings.server.port}";

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
      '';
    };
in
{
  users = {
    users.${config.services.radarr.user} = {
      group = config.services.radarr.group;
      uid = config.ids.uids.radarr;
    };

    groups.${config.services.radarr.group}.gid = config.ids.gids.radarr;
  };

  system.fsPackages = [ pkgs.bindfs ];
  fileSystems."${bindmountDir}" = {
    depends = [ "/mnt/Data/Movies" ];
    device = "/mnt/Data/Movies";
    fsType = "fuse.bindfs";
    noCheck = true;
    options = [
      "map=${
        lib.concatStringsSep ":" [
          "root/${config.services.radarr.user}"
          "@root/@${config.services.radarr.group}"
        ]
      }"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/radarr-anime 0750 ${config.services.radarr.user} ${config.services.radarr.group}"
    "d /var/lib/radarr-movies 0750 ${config.services.radarr.user} ${config.services.radarr.group}"

    "d ${rootBindmountDir} 0550 ${config.services.radarr.user} ${config.services.radarr.group}"
    "d ${bindmountDir} 0550 ${config.services.radarr.user} ${config.services.radarr.group}"
  ];

  containers = {
    radarr-anime = createContainer "anime";
    radarr-movies = createContainer "movies";
  };

  services = {
    monitoring.extraPrometheusJobs =
      map
        (
          type:
          let
            containerCfg = getContainerCfg type;
          in
          {
            name = "Radarr ${lib.toSentenceCase type}";
            url = "http://${
              config.containers."radarr-${type}".localAddress
            }:${toString containerCfg.services.prometheus.exporters.exportarr-radarr.port}/metrics";
          }
        )
        [
          "anime"
          "movies"
        ];

    infomaniak = {
      enable = true;

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
      hostnames = [
        "radarr.00a.ch"
      ];
    };

    nginx = {
      enable = true;

      virtualHosts."radarr.00a.ch" = {
        enableACME = true;
        acmeRoot = null;
        forceSSL = true;

        extraConfig = ''
          include /run/nginx-authelia/location.conf;
        '';

        locations = {
          "/".return = "302 /anime";

          "/anime" = createNginxVirtualHostLocation "anime";
          "/movies" = createNginxVirtualHostLocation "movies";
        };
      };
    };
  };
}
