{ config, lib, pkgs, secrets, ... }:
let
  rootBindmountDir = "/mnt/bindmount/sonarr";
  bindmountDir1 = "${rootBindmountDir}/resilio-TvShows";
  bindmountDir2 = "${rootBindmountDir}/disk-TvShows";
in {
  imports = [ ./deluge ./prowlarr.nix ];

  users.users.sonarr.extraGroups = [ config.services.deluge.group ];

  system.fsPackages = [ pkgs.bindfs ];
  fileSystems = {
    "${bindmountDir1}" = {
      depends = [ config.services.resilio.syncPath ];
      device = "${config.services.resilio.syncPath}/Series/Tv Shows";
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
      device = "/mnt/Data/Series/Tv Shows";
      fsType = "fuse.bindfs";
      options = [ "map=${lib.concatStringsSep ":" [ "root/${config.services.sonarr.user}" "@root/@${config.services.sonarr.group}" ]}" ];
    };
  };

  services = {
    sonarr.enable = true;

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
          proxyPass = "http://127.0.0.1:8989";
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
    after = [ "network.target" "sonarr.service" ];

    script = let
      pythonWithPackages = pkgs.python3.withPackages (ps: [ ps.pyjwt ps.requests ]);

      script = pkgs.substituteAll {
        src = ./update_series.py;

        sonarApiUrl = "http://127.0.0.1:8989";
        sonarApiKey = secrets.sonarr.apiKey;
        sonarrRootDir = bindmountDir1;

        tvTimeUsername = secrets.tvTime.username;
        tvTimePassword = secrets.tvTime.password;
      };
    in "${pythonWithPackages}/bin/python ${script}";

    startAt = "*:0/15";

    serviceConfig = {
      DynamicUser = true;
      Restart = "on-abort";
    };
  };
}
