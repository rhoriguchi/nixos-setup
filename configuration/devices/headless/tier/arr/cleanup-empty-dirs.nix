{
  config,
  lib,
  pkgs,
  ...
}:
{
  sops.secrets."cleanup-empty-dirs+services/jellyfin/apiKeys/cleanupEmptyDirs".key =
    "services/jellyfin/apiKeys/cleanupEmptyDirs";

  systemd.services.cleanup-empty-dirs = {
    after = [ config.systemd.services.jellyfin.name ];

    script = ''
      status=0
      deleted="$(${pkgs.findutils}/bin/find ${
        lib.concatStringsSep " " (
          map (path: ''"${path}"'') [
            "/mnt/Data/Movies"
            "/mnt/Data/Series"
            "${config.services.syncthing.dataDir}/Series"
          ]
        )
      } -type d -empty -print -delete)" || status=$?

      if [ -n "$deleted" ]; then
        echo "$deleted"

        echo "Triggering ${config.systemd.services.jellyfin.name} library refresh"
        ${pkgs.curl}/bin/curl ${
          lib.concatStringsSep " " [
            "--fail"
            "--request POST"
            "--show-error"
            "--silent"

            ''--header "Authorization: MediaBrowser Token=\"$(cat ${
              config.sops.secrets."cleanup-empty-dirs+services/jellyfin/apiKeys/cleanupEmptyDirs".path
            })\""''
          ]
        } "http://127.0.0.1:${toString config.services.declarative-jellyfin.network.internalHttpPort}/Library/Refresh" || status=1
      fi

      exit $status
    '';

    startAt = "*:0/5";

    serviceConfig = {
      Restart = "on-abort";
      Type = "oneshot";
    };
  };
}
