{
  config,
  lib,
  pkgs,
  ...
}:
let
  postgresBackupDir = "/var/lib/borgmatic/postgres";

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
        "/var/lib/hass/backups"
        "/var/lib/terraria"

        config.services.loki.dataDir
        config.services.minecraft-servers.dataDir
        config.services.plex.dataDir
        config.services.prowlarr.dataDir
        config.services.resilio.syncPath
        config.services.sonarr.dataDir
        config.services.tautulli.dataDir
      ]
      ++ lib.optional config.services.postgresql.enable postgresBackupDir;

      repositories = [
        {
          label = "local";
          path = backupDir;
        }
      ];
    };
  };

  # Workaround for peer based authentication and privileges escalation since service is hardened
  systemd = {
    services = lib.listToAttrs (
      map (
        database:
        lib.nameValuePair "borgmatic-postgres-dump-${database}" {
          wantedBy = [ "multi-user.target" ];
          after = [ config.systemd.services.postgresql.name ];

          script = ''
            ${config.services.postgresql.package}/bin/pg_dump ${
              lib.concatStringsSep " " [
                "--blobs"
                "--clean"
                "--format custom"
                "--if-exists"
              ]
            } ${database} > '${postgresBackupDir}/${database}.sql'
          '';

          serviceConfig = {
            User = database;
            Restart = "on-abort";
            Type = "oneshot";
          };
        }
      ) config.services.postgresql.ensureDatabases
    );

    timers = lib.listToAttrs (
      map (
        database:
        lib.nameValuePair "borgmatic-postgres-dump-${database}" {
          wantedBy = [ "timers.target" ];

          timerConfig = {
            OnCalendar = "daily";
            RandomizedDelaySec = 60 * 60;
          };
        }
      ) config.services.postgresql.ensureDatabases
    );
  };

  system.activationScripts = {
    borgmatic = ''
      # Disable error trap since list can fail if the backup is running
      trap - ERR

      mkdir -p '${backupDir}'

      if ! ${pkgs.borgbackup}/bin/borg list '${backupDir}' >/dev/null 2>&1; then
        ${pkgs.borgbackup}/bin/borg init --encryption=none '${backupDir}'
      fi

      # Enable error trap again
      trap "_status=1 _localstatus=\$?" ERR
    '';

    borgmatic-postgres-dump = lib.optionalString config.services.postgresql.enable ''
      mkdir -p '${postgresBackupDir}'
      chmod 777 '${postgresBackupDir}'
    '';
  };
}
