{
  config,
  lib,
  pkgs,
  ...
}:
let
  backupDir = "/mnt/Data/Backup/${config.networking.hostName}";

  storageBoxUser = "u723513";

  uptimeKumaCommands = tokenFile: [
    {
      after = "action";
      when = [ "create" ];
      states = [ "finish" ];
      run = [
        "${pkgs.curl}/bin/curl ${
          lib.concatStringsSep " " [
            "--fail"
            "--retry 3"
            "--show-error"
            "--silent"
          ]
        } 'https://uptime-kuma.00a.ch/api/push/'\"$(cat ${tokenFile})\"'?status=up&msg=OK&ping='"
      ];
    }
    {
      after = "error";
      run = [
        "${pkgs.curl}/bin/curl ${
          lib.concatStringsSep " " [
            "--fail"
            "--retry 3"
            "--show-error"
            "--silent"
          ]
        } 'https://uptime-kuma.00a.ch/api/push/'\"$(cat ${tokenFile})\"'?status=down&msg=Failed&ping='"
      ];
    }
  ];

  postgresqlDatabases = lib.mkIf config.services.postgresql.enable (
    map (database: {
      name = database;
      username = "postgres";
    }) config.services.postgresql.ensureDatabases
    ++ [
      {
        name = "tvtracktime";
        hostname = config.containers.tvtracktime-application.localAddress;
        port = config.containers.tvtracktime-application.config.services.postgresql.settings.port;
        username = "tvtracktime";
        password = "{credential file ${
          config.sops.secrets."borgmatic+services/tvTrackTime/postgres/password".path
        }}";

        options =
          lib.pipe
            [
              "api_key"
              "application_user"
              "jwt_token"
              "series_tag"
              "tag"
              "tracked_user_series"
              "user_episode_watch"
              "user_settings"
            ]
            [
              (map (table: "--table=${table}"))
              (lib.concatStringsSep " ")
            ];
      }
    ]
  );

  commonSettings = {
    statistics = true;
    list_details = true;

    verbosity = 0;
    syslog_verbosity = 1;

    postgresql_databases = postgresqlDatabases;
  };
in
{
  assertions = [
    {
      assertion = lib.versionOlder pkgs.borgbackup.version "1.5";
      message = "borgbackup ${pkgs.borgbackup.version} is no longer 1.4.x; revisit remote_path = \"borg-1.4\" for the Hetzner Storage Box in backup.nix.";
    }
  ];

  sops.secrets = {
    "borgmatic+services/tvTrackTime/postgres/password".key = "services/tvTrackTime/postgres/password";

    "services/borgmatic/storageBox/passphrase" = { };
    "services/borgmatic/storageBox/sshPrivateKey" = { };
    "services/uptime-kuma/pushTokens/borgmaticBackup" = { };
    "services/uptime-kuma/pushTokens/borgmaticBackupRemote" = { };
  };

  services.borgmatic = {
    enable = true;

    settings = lib.mkMerge [
      commonSettings

      {
        keep_daily = 7;
        keep_weekly = 4;
        keep_monthly = 3;

        source_directories = [
          "/mnt/Data/Movies"
          "/mnt/Data/Series"

          "/var/cache/netdata"
          "/var/lib/${config.services.prometheus.stateDir}"
          "/var/lib/bazarr-anime"
          "/var/lib/bazarr-series-movies"
          "/var/lib/radarr-anime"
          "/var/lib/radarr-movies"
          "/var/lib/sonarr-anime"
          "/var/lib/sonarr-series"

          "/var/lib/private/mealie"
          "/var/lib/private/prowlarr"

          config.services.couchdb.databaseDir
          config.services.home-assistant.configDir
          config.services.jellyfin.dataDir
          config.services.loki.dataDir
          config.services.plex.dataDir
          config.services.syncthing.dataDir
          config.services.tautulli.dataDir
          config.services.tempo.settings.storage.trace.local.path
        ];

        repositories = [
          {
            label = "local";
            path = backupDir;
          }
        ];

        commands =
          uptimeKumaCommands
            config.sops.secrets."services/uptime-kuma/pushTokens/borgmaticBackup".path;
      }
    ];

    configurations.remote = lib.mkMerge [
      commonSettings

      {
        keep_secondly = 1;

        checks = [
          {
            name = "repository";
            frequency = "1 week";
          }
        ];

        encryption_passphrase = "{credential file ${
          config.sops.secrets."services/borgmatic/storageBox/passphrase".path
        }}";

        ssh_command = lib.concatStringsSep " " [
          "${pkgs.openssh}/bin/ssh"
          "-i ${config.sops.secrets."services/borgmatic/storageBox/sshPrivateKey".path}"
          "-o IdentitiesOnly=yes"
          "-o StrictHostKeyChecking=accept-new"
        ];

        remote_path = "borg-1.4";

        source_directories = [
          "/var/lib/bazarr-anime"
          "/var/lib/bazarr-series-movies"
          "/var/lib/radarr-anime"
          "/var/lib/radarr-movies"
          "/var/lib/sonarr-anime"
          "/var/lib/sonarr-series"

          "/var/lib/private/mealie"
          "/var/lib/private/prowlarr"

          config.services.couchdb.databaseDir
          config.services.home-assistant.configDir
          config.services.loki.dataDir
          config.services.plex.dataDir
          config.services.syncthing.dataDir
        ];

        exclude_patterns = [ "${config.services.syncthing.dataDir}/Series" ];

        repositories = [
          {
            label = "storage-box";
            path = "ssh://${storageBoxUser}@${storageBoxUser}.your-storagebox.de:23/./${config.networking.hostName}";
          }
        ];

        commands =
          uptimeKumaCommands
            config.sops.secrets."services/uptime-kuma/pushTokens/borgmaticBackupRemote".path;
      }
    ];
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
