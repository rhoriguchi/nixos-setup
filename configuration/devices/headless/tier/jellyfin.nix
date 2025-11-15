{
  config,
  lib,
  pkgs,
  secrets,
  ...
}:
let
  rootBindmountDir = "/mnt/bindmount/jellyfin";
  bindmountDir1 = "${rootBindmountDir}/resilio-Movies";
  bindmountDir2 = "${rootBindmountDir}/resilio-Series";
  bindmountDir3 = "${rootBindmountDir}/disk-Movies";
  bindmountDir4 = "${rootBindmountDir}/disk-Series";
in
{
  system.fsPackages = [ pkgs.bindfs ];
  fileSystems = {
    "${bindmountDir1}" = {
      depends = [ config.services.resilio.syncPath ];
      device = "${config.services.resilio.syncPath}/Movies";
      fsType = "fuse.bindfs";
      options = [
        # `ro` causes kernel panic
        "perms=0550"
        "map=${
          lib.concatStringsSep ":" [
            "${config.services.resilio.user}/${config.services.jellyfin.user}"
            "@${config.services.resilio.group}/@${config.services.jellyfin.group}"
          ]
        }"
      ];
    };

    "${bindmountDir2}" = {
      depends = [ config.services.resilio.syncPath ];
      device = "${config.services.resilio.syncPath}/Series";
      fsType = "fuse.bindfs";
      options = [
        # `ro` causes kernel panic
        "perms=0550"
        "map=${
          lib.concatStringsSep ":" [
            "${config.services.resilio.user}/${config.services.jellyfin.user}"
            "@${config.services.resilio.group}/@${config.services.jellyfin.group}"
          ]
        }"
      ];
    };

    "${bindmountDir3}" = {
      depends = [ "/mnt/Data/Movies" ];
      device = "/mnt/Data/Movies";
      fsType = "fuse.bindfs";
      options = [
        # `ro` causes kernel panic
        "perms=0550"
        "map=${
          lib.concatStringsSep ":" [
            "root/${config.services.jellyfin.user}"
            "@root/@${config.services.jellyfin.group}"
          ]
        }"
      ];
    };

    "${bindmountDir4}" = {
      depends = [ "/mnt/Data/Series" ];
      device = "/mnt/Data/Series";
      fsType = "fuse.bindfs";
      options = [
        # `ro` causes kernel panic
        "perms=0550"
        "map=${
          lib.concatStringsSep ":" [
            "root/${config.services.jellyfin.user}"
            "@root/@${config.services.jellyfin.group}"
          ]
        }"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d ${rootBindmountDir} 0550 ${config.services.jellyfin.user} ${config.services.jellyfin.group}"
    "d ${bindmountDir1} 0550 ${config.services.jellyfin.user} ${config.services.jellyfin.group}"
    "d ${bindmountDir2} 0550 ${config.services.jellyfin.user} ${config.services.jellyfin.group}"
    "d ${bindmountDir3} 0550 ${config.services.jellyfin.user} ${config.services.jellyfin.group}"
    "d ${bindmountDir4} 0550 ${config.services.jellyfin.user} ${config.services.jellyfin.group}"
  ];

  services = {
    jellyfin = {
      enable = true;

      logDir = "/var/log/jellyfin";
    };

    infomaniak = {
      enable = true;

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
      hostnames = [ "jellyfin.00a.ch" ];
    };

    nginx = {
      enable = true;

      virtualHosts."jellyfin.00a.ch" = {
        enableACME = true;
        forceSSL = true;

        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:8096";
            proxyWebsockets = true;

            extraConfig = ''
              proxy_buffering off;
            '';
          };

          "/metrics".return = 403;
        };
      };
    };
  };

  networking.firewall.allowedUDPPorts = [ 7359 ];
}

# TODO check if this works
# Client Discovery (7359/UDP): Allows clients to discover Jellyfin on the local network. A broadcast message to this
# port will return detailed information about your server that includes name, ip-address and ID.
