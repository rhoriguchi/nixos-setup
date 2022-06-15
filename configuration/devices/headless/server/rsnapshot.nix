{ pkgs, lib, config, ... }:
let
  backupDir = "/mnt/Data/Backup";

  preExecShellScript = pkgs.writeShellScript "rsnapshot-preExec" ''
    mkdir -p ${backupDir}
  '';

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

    cronIntervals = {
      daily = "0 5 * * *";
      weekly = "0 6 * * 1";
      monthly = "0 7 1 * *";
    };

    extraConfig = ''
      verbose	1
      rsync_long_args	${rsyncLongArgs}

      cmd_preexec	${preExecShellScript}

      snapshot_root	${backupDir}

      retain	daily	7
      retain	weekly	4
      retain	monthly	3

      backup	${config.services.plex.dataDir}/	./
      backup	${config.services.resilio.syncPath}/	./
      backup	${config.services.tautulli.dataDir}/	./
    '';
  };
}
