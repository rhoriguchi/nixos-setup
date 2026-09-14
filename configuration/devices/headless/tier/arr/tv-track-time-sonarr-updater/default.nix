{
  config,
  lib,
  pkgs,
  ...
}:
let
  pythonScript =
    pkgs.writers.writePython3 "tv-track-time-sonarr-updater"
      {
        libraries = [
          pkgs.python3Packages.requests
        ];

        flakeIgnore = [ "E501" ];
      }
      (
        lib.readFile (
          pkgs.replaceVars ./script.py {
            sonarApiUrl = "http://${config.containers.sonarr-series.localAddress}:${toString config.services.sonarr.settings.server.port}";
            sonarrRootDir = "/mnt/bindmount/sonarr/sync-Series/Tv Shows";

            tvTrackTimeApiUrl = "http://${config.containers.tvtracktime-application.localAddress}:8080";

            excludedTvdbIds =
              lib.pipe
                [ ]
                [
                  (map toString)
                  (lib.concatStringsSep ", ")
                ];
          }
        )
      );
in
{
  sops.secrets = {
    "services/sonarr/apiKey" = { };
    "services/tvTrackTimeSonarrUpdater/apiKey" = { };
  };

  systemd.services.tv-track-time-sonarr-updater = {
    after = [
      "network.target"
      config.systemd.services."container@sonarr-series".name
    ];

    script = "${pythonScript}";

    startAt = "*:0/15";

    serviceConfig = {
      DynamicUser = true;
      Restart = "on-abort";
      Type = "oneshot";

      LoadCredential = [
        "sonarApiKey:${config.sops.secrets."services/sonarr/apiKey".path}"
        "tvTrackTimeApiKey:${config.sops.secrets."services/tvTrackTimeSonarrUpdater/apiKey".path}"
      ];
    };
  };
}
