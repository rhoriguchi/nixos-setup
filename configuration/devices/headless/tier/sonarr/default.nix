{
  config,
  lib,
  pkgs,
  secrets,
  ...
}:
let
  rootBindmountDir = "/mnt/bindmount/sonarr";
  bindmountDir1 = "${rootBindmountDir}/resilio-Series";
  bindmountDir2 = "${rootBindmountDir}/disk-Series";

  createContainer =
    type:
    let
      containerCfg = config.containers."sonarr-${type}".config;
    in
    {
      autoStart = true;
      ephemeral = true;

      privateNetwork = true;
      hostAddress = "169.254.1.1";
      localAddress =
        {
          anime = "169.254.1.3";
          series = "169.254.1.4";
        }
        .${type};

      forwardPorts = [
        {
          containerPort = config.services.sonarr.settings.server.port;
          hostPort = containerCfg.services.sonarr.settings.server.port;
          protocol = "tcp";
        }
      ];

      bindMounts = {
        "${containerCfg.services.sonarr.dataDir}" = {
          isReadOnly = false;
          hostPath = "/var/lib/sonarr-${type}";
        };

        "${bindmountDir1}" = {
          isReadOnly = false;
          hostPath = bindmountDir1;
        };

        "${bindmountDir2}" = {
          isReadOnly = false;
          hostPath = bindmountDir2;
        };

        "/mnt/Data/Deluge" = {
          isReadOnly = false;
          hostPath = "/mnt/Data/Deluge";
        };
      };

      config = {
        system = {
          inherit (config.system) stateVersion;
        };

        users = {
          users = {
            "${config.services.sonarr.user}".extraGroups = [ config.services.deluge.group ];

            "${config.services.deluge.user}" = {
              group = config.services.deluge.group;
              uid = config.ids.uids.deluge;
              home = config.services.deluge.dataDir;
            };
          };

          groups.${config.services.deluge.group}.gid = config.ids.gids.deluge;
        };

        services.sonarr = {
          enable = true;

          openFirewall = true;

          # https://wiki.servarr.com/sonarr/environment-variables
          settings = {
            app.instancename = "Sonarr ${lib.toSentenceCase type}";

            server.urlbase = "/${type}";

            auth = {
              apikey = secrets.sonarr.apiKey;
              method = "Forms";
              required = "DisabledForLocalAddresses";
            };
          };
        };
      };
    };

  createNginxVirtualHostLocation = type: {
    proxyPass = "http://${
      config.containers."sonarr-${type}".localAddress
    }:${toString config.services.sonarr.settings.server.port}";
    basicAuth = secrets.nginx.basicAuth."sonarr.00a.ch";

    recommendedProxySettings = false;
    extraConfig = ''
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP 127.0.0.1;
      proxy_set_header X-Forwarded-For 127.0.0.1;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_set_header X-Forwarded-Host $host;
      proxy_set_header X-Forwarded-Server $host;

      satisfy any;

      allow 192.168.2.0/24;
      deny all;
    '';
  };
in
{
  imports = [
    ./deluge
    ./prowlarr.nix
    ./recyclarr.nix
    ./sonarr-tv-time-updater
  ];

  users = {
    users.${config.services.sonarr.user} = {
      group = config.services.sonarr.group;
      uid = config.ids.uids.sonarr;
    };

    groups.${config.services.sonarr.group}.gid = config.ids.gids.sonarr;
  };

  system.fsPackages = [ pkgs.bindfs ];
  fileSystems = {
    "${bindmountDir1}" = {
      depends = [ config.services.resilio.syncPath ];
      device = "${config.services.resilio.syncPath}/Series";
      fsType = "fuse.bindfs";
      options = [
        "map=${
          lib.concatStringsSep ":" [
            "${config.services.resilio.user}/${config.services.sonarr.user}"
            "@${config.services.resilio.group}/@${config.services.sonarr.group}"
          ]
        }"
      ];
    };

    "${bindmountDir2}" = {
      depends = [ "/mnt/Data/Series" ];
      device = "/mnt/Data/Series";
      fsType = "fuse.bindfs";
      options = [
        "map=${
          lib.concatStringsSep ":" [
            "root/${config.services.sonarr.user}"
            "@root/@${config.services.sonarr.group}"
          ]
        }"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/sonarr-anime 0750 ${config.services.sonarr.user} ${config.services.sonarr.group}"
    "d /var/lib/sonarr-series 0750 ${config.services.sonarr.user} ${config.services.sonarr.group}"

    "d ${rootBindmountDir} 0550 ${config.services.sonarr.user} ${config.services.sonarr.group}"
    "d ${bindmountDir1} 0550 ${config.services.sonarr.user} ${config.services.sonarr.group}"
    "d ${bindmountDir2} 0550 ${config.services.sonarr.user} ${config.services.sonarr.group}"
  ];

  containers = {
    sonarr-anime = createContainer "anime";
    sonarr-series = createContainer "series";
  };

  services = {
    infomaniak = {
      enable = true;

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
      hostnames = [
        "sonarr.00a.ch"
      ];
    };

    nginx = {
      enable = true;

      virtualHosts."sonarr.00a.ch" = {
        enableACME = true;
        forceSSL = true;

        locations = {
          "/anime" = createNginxVirtualHostLocation "anime";
          "/series" = createNginxVirtualHostLocation "series";

          "/".return = 444;
        };
      };
    };
  };
}
