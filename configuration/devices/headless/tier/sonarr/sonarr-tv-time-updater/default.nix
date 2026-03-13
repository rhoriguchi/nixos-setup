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
      config.systemd.services."container@sonarr-series".name
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
                  sonarApiUrl = "http://${config.containers.sonarr-series.localAddress}:${toString config.services.sonarr.settings.server.port}";
                  sonarApiKey = secrets.sonarr.apiKey;
                  sonarrRootDir = "/mnt/bindmount/sonarr/resilio-Series/Tv Shows";

                  tvTimeUsername = secrets.tvTime.username;
                  tvTimePassword = secrets.tvTime.password;

                  excludedTvdbIds = lib.concatStringsSep ", " (
                    map (tvdbId: toString tvdbId) [
                      366924 # Reacher(2022)
                      371980 # Severance(2022)
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
