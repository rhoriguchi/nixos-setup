{ config, lib, pkgs, ... }:
let
  rootBindmountDir = "/mnt/bindmount/plex";
  bindmountDir1 = "${rootBindmountDir}/resilio-Movies";
  bindmountDir2 = "${rootBindmountDir}/resilio-Series";
  bindmountDir3 = "${rootBindmountDir}/disk-Movies";
  bindmountDir4 = "${rootBindmountDir}/disk-Series";
in {
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
            "${config.services.resilio.user}/${config.services.plex.user}"
            "@${config.services.resilio.group}/@${config.services.plex.group}"
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
            "${config.services.resilio.user}/${config.services.plex.user}"
            "@${config.services.resilio.group}/@${config.services.plex.group}"
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
        "map=${lib.concatStringsSep ":" [ "root/${config.services.plex.user}" "@root/@${config.services.plex.group}" ]}"
      ];
    };

    "${bindmountDir4}" = {
      depends = [ "/mnt/Data/Series" ];
      device = "/mnt/Data/Series";
      fsType = "fuse.bindfs";
      options = [
        # `ro` causes kernel panic
        "perms=0550"
        "map=${lib.concatStringsSep ":" [ "root/${config.services.plex.user}" "@root/@${config.services.plex.group}" ]}"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d ${rootBindmountDir} 0550 ${config.services.plex.user} ${config.services.plex.group}"
    "d ${bindmountDir1} 0550 ${config.services.plex.user} ${config.services.plex.group}"
    "d ${bindmountDir2} 0550 ${config.services.plex.user} ${config.services.plex.group}"
    "d ${bindmountDir3} 0550 ${config.services.plex.user} ${config.services.plex.group}"
    "d ${bindmountDir4} 0550 ${config.services.plex.user} ${config.services.plex.group}"
  ];

  services.plex = {
    enable = true;

    openFirewall = true;

    extraPlugins = [
      (builtins.path {
        name = "MyAnimeList.bundle";
        path = pkgs.fetchFromGitHub {
          owner = "Fribb";
          repo = "MyAnimeList.bundle";
          tag = "v7.4.2";
          hash = "sha256-g2VEsJaVucWk2jwm6EStuq5Age8aqpn/EiMupU3i7Hw=";
        };
      })
    ];
    extraScanners = [
      (pkgs.fetchFromGitHub {
        owner = "ZeroQI";
        repo = "Absolute-Series-Scanner";
        rev = "f41cd58eb72480c677ec6c9efec9de6adbad16ff";
        hash = "sha256-XE1yHsJQo9o46NlE5ToIhK4EXONFKjANtKY3dpTs9HE=";
      })
    ];
  };
}
