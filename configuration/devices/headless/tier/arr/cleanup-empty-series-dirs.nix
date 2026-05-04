{
  config,
  pkgs,
  ...
}:
{
  systemd.services.cleanup-empty-series-dirs = {
    after = [ "default.target" ];

    script = "${pkgs.findutils}/bin/find ${config.services.syncthing.dataDir}/Series -type d -empty -print -delete";

    startAt = "*:0/5";

    serviceConfig = {
      Restart = "on-abort";
      Type = "oneshot";
    };
  };
}
