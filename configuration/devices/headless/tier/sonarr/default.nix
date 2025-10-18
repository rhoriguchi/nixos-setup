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
in
{
  imports = [
    ./deluge
    ./prowlarr.nix
    ./recyclarr.nix
  ];

  users.users.sonarr.extraGroups = [ config.services.deluge.group ];

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
    "d ${rootBindmountDir} 0550 ${config.services.sonarr.user} ${config.services.sonarr.group}"
    "d ${bindmountDir1} 0550 ${config.services.sonarr.user} ${config.services.sonarr.group}"
    "d ${bindmountDir2} 0550 ${config.services.sonarr.user} ${config.services.sonarr.group}"
  ];

  services = {
    sonarr.enable = true;

    prometheus.exporters.exportarr-sonarr.environment.API_KEY = secrets.sonarr.apiKey;

    infomaniak = {
      enable = true;

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
      hostnames = [ "sonarr.00a.ch" ];
    };

    nginx = {
      enable = true;

      virtualHosts."sonarr.00a.ch" = {
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.sonarr.settings.server.port}";
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
      };
    };
  };

  systemd.services.sonarr-update-tracked-series = {
    after = [
      "network.target"
      config.systemd.services.sonarr.name
    ];

    script =
      let
        pythonScript =
          pkgs.writers.writePython3 "update_series.py"
            {
              libraries = [
                pkgs.python3Packages.pyjwt
                pkgs.python3Packages.requests
              ];

              flakeIgnore = [ "E501" ];
            }
            (
              lib.readFile (
                pkgs.replaceVars ./update_series.py {
                  sonarApiUrl = "http://127.0.0.1:${toString config.services.sonarr.settings.server.port}";
                  sonarApiKey = secrets.sonarr.apiKey;
                  sonarrRootDir = "${bindmountDir1}/Tv Shows";

                  tvTimeUsername = secrets.tvTime.username;
                  tvTimePassword = secrets.tvTime.password;

                  excludedTvdbIds = lib.concatStringsSep ", " (
                    map (tvdbId: toString tvdbId) [
                      366924 # Reacher
                      371980 # Severance
                      393204 # Ironheart
                      397060 # Wednesday
                      422712 # Daredevil: Born Again
                    ]
                  );
                }
              )
            );
      in
      "${pythonScript}";

    startAt = "*:0/15";

    serviceConfig = {
      DynamicUser = true;
      Restart = "on-abort";
      Type = "oneshot";
    };
  };
}
