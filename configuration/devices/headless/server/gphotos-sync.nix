{ config, lib, pkgs, secrets, ... }:
let
  rootBindmountDir = "/mnt/bindmount/${config.services.gphotos-sync.user}";
  bindmountDir = "${rootBindmountDir}/resilio-Google_Photos";
in {
  system.fsPackages = [ pkgs.bindfs ];
  fileSystems.${bindmountDir} = {
    depends = [ config.services.resilio.syncPath ];
    device = "${config.services.resilio.syncPath}/Google_Photos";
    fsType = "fuse.bindfs";
    options = [
      "map=${
        lib.concatStringsSep ":" [
          "${config.services.resilio.user}/${config.services.gphotos-sync.user}"
          "@${config.services.resilio.group}/@${config.services.gphotos-sync.group}"
        ]
      }"
    ];
  };

  system.activationScripts.gphotos-sync = ''
    mkdir -p ${bindmountDir}
    chown -R ${config.services.gphotos-sync.user}:${config.services.gphotos-sync.group} ${rootBindmountDir}
  '';

  services.gphotos-sync = {
    enable = true;

    projectId = secrets.gphotosSync.projectId;
    clientId = secrets.gphotosSync.clientId;
    clientSecret = secrets.gphotosSync.clientSecret;
    exportPath = bindmountDir;
  };
}
