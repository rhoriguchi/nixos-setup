{
  config,
  lib,
  pkgs,
  secrets,
  ...
}:
{
  systemd.services.sonarr-tv-time-updater = {
    after = [
      "network.target"
      config.systemd.services.sonarr.name
    ];

    script =
      let
        pythonScript =
          pkgs.writers.writePython3 "update_series.py"
            {
              libraries = [
                pkgs.python3Packages.pyjwt
                pkgs.python3Packages.requests
              ];

              flakeIgnore = [ "E501" ];
            }
            (
              lib.readFile (
                pkgs.replaceVars ./script.py {
                  sonarApiUrl = "http://127.0.0.1:${toString config.services.sonarr.settings.server.port}";
                  sonarApiKey = secrets.sonarr.apiKey;
                  sonarrRootDir = "/mnt/bindmount/sonarr/resilio-Series/Tv Shows";

                  tvTimeUsername = secrets.tvTime.username;
                  tvTimePassword = secrets.tvTime.password;

                  excludedTvdbIds = lib.concatStringsSep ", " (
                    map (tvdbId: toString tvdbId) [
                      366924 # Reacher
                      371980 # Severance
                      393204 # Ironheart
                      397060 # Wednesday
                      422712 # Daredevil: Born Again
                    ]
                  );
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
