{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Can't use `config.users.users.rhoriguchi.home`
  # TODO change to `/home/rhoriguchi/Sync`
  bindmountDir = "/home/rhoriguchi/Sync-TEMP";
in
{
  system.fsPackages = [ pkgs.bindfs ];
  # TODO commented causes kernel panic
  # fileSystems.${bindmountDir} = {
  #   depends = [ config.services.syncthing.dataDir ];
  #   device = config.services.syncthing.dataDir;
  #   fsType = "fuse.bindfs";
  #   noCheck = true;
  #   options = [
  #     "perms=0750"
  #     "map=${
  #       lib.concatStringsSep ":" [
  #         "${config.services.syncthing.user}/rhoriguchi"
  #         "@${config.services.syncthing.group}/rhoriguchi"
  #       ]
  #     }"
  #   ];
  # };

  systemd.tmpfiles.rules = [
    "d ${bindmountDir} 0750 rhoriguchi rhoriguchi"
  ];

  services.custom-syncthing = {
    gui = {
      enable = true;

      # TODO comment
      # username = "admin";
      # password = secrets.resilio.webUI.password;
    };

    trashcan.enable = true;
  };
}
