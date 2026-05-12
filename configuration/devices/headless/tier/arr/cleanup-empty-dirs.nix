{
  config,
  lib,
  pkgs,
  ...
}:
{
  systemd.services.cleanup-empty-dirs = {
    after = [ "default.target" ];

    script = "${pkgs.findutils}/bin/find ${
      lib.concatStringsSep " " (
        map (path: ''"${path}"'') [
          "/mnt/Data/Movies"
          "/mnt/Data/Series"
          "${config.services.syncthing.dataDir}/Series"
        ]
      )
    } -type d -empty -print -delete";

    startAt = "*:0/5";

    serviceConfig = {
      Restart = "on-abort";
      Type = "oneshot";
    };
  };
}
