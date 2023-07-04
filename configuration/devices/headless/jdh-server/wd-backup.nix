{ pkgs, lib, ... }: {
  systemd.services.wd-backup-tv-shows = {
    after = [ "network.target" ];

    script = let
      args = lib.concatStringsSep " " [
        "--copy-links"
        "--delete"
        "--force"
        "--no-group"
        "--no-owner"
        "--no-perms"
        "--numeric-ids"
        "--recursive"
        "--times"
      ];
    in ''${pkgs.rsync}/bin/rsync ${args} "/mnt/Media/Videos/TV Shows WD/" "/mnt/WD_Backup/TV Shows"'';

    startAt = "Wed *-*-* 13:00:00";

    serviceConfig.Restart = "on-abort";
  };
}
