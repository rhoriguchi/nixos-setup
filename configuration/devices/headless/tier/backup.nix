{
  config,
  lib,
  pkgs,
  secrets,
  ...
}:
let
  backupDir = "/mnt/Data/Backup/${config.networking.hostName}";
in
{
  services.borgmatic = {
    enable = true;

    settings = {
      statistics = true;
      list_details = true;

      verbosity = 0;
      syslog_verbosity = 1;

      keep_daily = 7;
      keep_weekly = 4;
      keep_monthly = 3;

      source_directories = [
        "/mnt/Data/Movies"
        "/mnt/Data/Series"

        "/var/cache/netdata"
        "/var/lib/${config.services.prometheus.stateDir}"
        "/var/lib/bazarr-anime"
        "/var/lib/bazarr-series"
        "/var/lib/sonarr-anime"
        "/var/lib/sonarr-series"
        "/var/lib/terraria"

        config.services.home-assistant.configDir
        config.services.jellyfin.dataDir
        config.services.loki.dataDir
        config.services.minecraft-servers.dataDir
        config.services.plex.dataDir
        config.services.prowlarr.dataDir
        config.services.resilio.syncPath
        config.services.tautulli.dataDir
      ];

      repositories = [
        {
          label = "local";
          path = backupDir;
        }
      ];

      after_backup = [
        "${pkgs.curl}/bin/curl ${
          lib.concatStringsSep " " [
            "--fail"
            "--retry 3"
            "--show-error"
            "--silent"
          ]
        } 'https://uptime-kuma.00a.ch/api/push/${secrets.uptime-kuma.pushTokens.borgmaticBackup}?status=up&msg=OK&ping='"
      ];

      on_error = [
        "${pkgs.curl}/bin/curl ${
          lib.concatStringsSep " " [
            "--fail"
            "--retry 3"
            "--show-error"
            "--silent"
          ]
        } 'https://uptime-kuma.00a.ch/api/push/${secrets.uptime-kuma.pushTokens.borgmaticBackup}=down&msg=OK&ping='"
      ];
    }
    // lib.optionalAttrs config.services.postgresql.enable {
      postgresql_databases = map (database: {
        name = database;
        username = database;
      }) config.services.postgresql.ensureDatabases;
    };
  };

  system.activationScripts.borgmatic = ''
    # Disable error trap since list can fail if the backup is running
    trap - ERR

    mkdir -p '${backupDir}'

    if ! ${pkgs.borgbackup}/bin/borg list '${backupDir}' >/dev/null 2>&1; then
      ${pkgs.borgbackup}/bin/borg init --encryption=none '${backupDir}'
    fi

    # Enable error trap again
    trap "_status=1 _localstatus=\$?" ERR
  '';
}
