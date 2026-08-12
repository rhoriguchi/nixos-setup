{
  config,
  lib,
  pkgs,
  secrets,
  ...
}:
{
  systemd.services.sonarr-tv-track-time-updater = {
    after = [
      "network.target"
      config.systemd.services."container@sonarr-series".name
    ];

    script =
      let
        pythonScript =
          pkgs.writers.writePython3 "tv-track-time"
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
                  sonarApiKey = secrets.sonarr.apiKey;
                  sonarrRootDir = "/mnt/bindmount/sonarr/sync-Series/Tv Shows";

                  tvTrackTimeApiUrl = "http://${config.containers.tvtracktime-application.localAddress}:8080";
                  tvTrackTimeUsername = secrets.tvTrackTimeSonarrUpdater.username;
                  tvTrackTimePassword = secrets.tvTrackTimeSonarrUpdater.password;

                  excludedTvdbIds =
                    lib.pipe
                      [
                        366924 # Reacher(2022)
                        371980 # Severance(2022)
                        422712 # Daredevil: Born Again
                      ]
                      [
                        (map toString)
                        (lib.concatStringsSep ", ")
                      ];
                }
              )
            );
      in
      "${pythonScript}";

    startAt = "*:0/15";

    serviceConfig = {
      DynamicUser = true;
      Restart = "on-abort";
      Type = "oneshot";
    };
  };
}
