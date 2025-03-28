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

  system.activationScripts.plex = ''
    mkdir -p ${bindmountDir1}
    mkdir -p ${bindmountDir2}
    mkdir -p ${bindmountDir3}
    mkdir -p ${bindmountDir4}
    chown -R ${config.services.plex.user}:${config.services.plex.group} ${rootBindmountDir}
  '';

  services.plex = {
    enable = true;

    openFirewall = true;

    extraPlugins = [
      (builtins.path {
        name = "MyAnimeList.bundle";
        path = pkgs.fetchFromGitHub {
          owner = "Fribb";
          repo = "MyAnimeList.bundle";
          tag = "v7.4.1";
          hash = "sha256-hqdhz1FyzwgLHcxMRSuSuwNLuqDhdy+t6KCZhESgAho=";
        };
      })
    ];
    extraScanners = [
      (pkgs.fetchFromGitHub {
        owner = "ZeroQI";
        repo = "Absolute-Series-Scanner";
        rev = "ddca35eecb2377e727850e0497bc9b1f67fc11e7";
        hash = "sha256-xMZPSi6+YUNFJjNmiiIBN713A/2PKDuQ1Iwm5c/Qt+s=";
      })
    ];
  };
}
