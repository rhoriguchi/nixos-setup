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

  system.activationScripts.bindmount-plex = ''
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
          tag = "v7.4.2";
          hash = "sha256-g2VEsJaVucWk2jwm6EStuq5Age8aqpn/EiMupU3i7Hw=";
        };
      })
    ];
    extraScanners = [
      (pkgs.fetchFromGitHub {
        owner = "ZeroQI";
        repo = "Absolute-Series-Scanner";
        rev = "43df2ee5de503221d9d4e96e399ca2eca8f19859";
        hash = "sha256-AvWUNkne9JfM6WrzoaLfOHu6NhZofS0vE+xjzxwLtzs=";
      })
    ];
  };
}
