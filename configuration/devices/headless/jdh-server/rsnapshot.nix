{ pkgs, lib, config, ... }:
let
  rsyncLongArgs = lib.concatStringsSep " " [
    # rsnapshot requires these args
    "--delete-excluded"
    "--delete"
    "--relative"
    "--numeric-ids"

    "--copy-links"
    "--force"
    "--no-group"
    "--no-owner"
    "--no-perms"
    "--recursive"
    "--times"
  ];
in {
  services.rsnapshot = {
    enable = true;

    cronIntervals.weekly = "0 9 * * 3";
    extraConfig = ''
      verbose	1
      rsync_long_args	${rsyncLongArgs}

      snapshot_root	/mnt/Backup

      retain	weekly	52

      backup	${config.services.tautulli.dataDir}/	./
      backup	${config.services.plex.dataDir}/	./
    '';
  };
}
