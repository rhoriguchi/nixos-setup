{
  config,
  lib,
  pkgs,
  ...
}:
let
  common = import ./_common.nix { inherit config; };

  endpoint = "fsn1.your-objectstorage.com";
  region = "fsn1";
  bucket = "xxlpitu-tier-kopia";

  stateDir = "/var/lib/kopia";
  dumpDir = "${stateDir}/dumps";

  tvtracktime = config.containers.tvtracktime-application;
  tvtracktimePostgres = tvtracktime.config.services.postgresql;

  postgresDumpUnits = map (
    database: "postgresqlBackup-${database}.service"
  ) config.services.postgresqlBackup.databases;

  repositoryArgs = lib.escapeShellArgs [
    "--endpoint=${endpoint}"
    "--region=${region}"
    "--bucket=${bucket}"
  ];

  # Exact paths from the shared source list that are NOT backed up remotely
  excludes = [ ];

  # borgmatic streams DB dumps through hooks, kopia has no such hook so the
  # dumps are extra directories that only the remote backup has
  allSources = common.sources ++ [
    config.services.postgresqlBackup.location
    dumpDir
  ];

  # Exact string matches only, no globbing or prefix matching
  sources = lib.subtractLists excludes allSources;
in
{
  assertions = [
    {
      assertion = lib.all (path: lib.elem path allSources) excludes;
      message = "remote backup excludes contain paths that are not backup sources: ${lib.concatStringsSep ", " (lib.subtractLists allSources excludes)}";
    }
  ];

  sops = {
    secrets = {
      "kopia+services/tvTrackTime/postgres/password".key = "services/tvTrackTime/postgres/password";

      "services/kopia/password" = { };
      "services/kopia/s3/accessKey" = { };
      "services/kopia/s3/secretKey" = { };

      "services/uptime-kuma/pushTokens/kopiaBackup" = { };
    };

    templates."services.kopia.environmentFile".content = ''
      AWS_ACCESS_KEY_ID=${config.sops.placeholder."services/kopia/s3/accessKey"}
      AWS_SECRET_ACCESS_KEY=${config.sops.placeholder."services/kopia/s3/secretKey"}
      KOPIA_PASSWORD=${config.sops.placeholder."services/kopia/password"}
    '';
  };

  services.postgresqlBackup = lib.mkIf config.services.postgresql.enable {
    enable = true;
    databases = config.services.postgresql.ensureDatabases;

    # Triggered by kopia-backup.service
    startAt = [ ];
  };

  systemd = {
    services.kopia-backup = {
      description = "Kopia backup to Hetzner Object Storage";

      requires = postgresDumpUnits ++ [ "network-online.target" ];
      after = postgresDumpUnits ++ [ "network-online.target" ];

      path = [
        pkgs.coreutils
        pkgs.curl
        pkgs.gzip
        pkgs.kopia
        tvtracktimePostgres.package
      ];

      environment = {
        KOPIA_CONFIG_PATH = "${stateDir}/repository.config";
        KOPIA_CACHE_DIRECTORY = "/var/cache/kopia";
        KOPIA_LOG_DIR = "/var/log/kopia";
        KOPIA_CHECK_FOR_UPDATES = "false";
      };

      serviceConfig = {
        Type = "oneshot";
        EnvironmentFile = config.sops.templates."services.kopia.environmentFile".path;
        StateDirectory = "kopia";
        StateDirectoryMode = "0700";
        CacheDirectory = "kopia";
        LogsDirectory = "kopia";
        Nice = 19;
        IOSchedulingClass = "idle";
      };

      script = ''
        set -euo pipefail

        notify() {
          curl --fail --retry 3 --show-error --silent \
            "https://uptime-kuma.00a.ch/api/push/$(cat ${
              config.sops.secrets."services/uptime-kuma/pushTokens/kopiaBackup".path
            })?status=$1&msg=$2&ping="
        }
        trap 'notify down FAILED' ERR

        # tvtracktime lives in a container, so it is dumped over TCP here
        mkdir -p ${dumpDir}
        PGPASSWORD="$(cat ${
          config.sops.secrets."kopia+services/tvTrackTime/postgres/password".path
        })" pg_dump \
          --host=${tvtracktime.localAddress} \
          --port=${toString tvtracktimePostgres.settings.port} \
          --username=tvtracktime \
          ${lib.concatMapStringsSep " " (table: "--table=${table}") common.tvtracktimeTables} \
          tvtracktime \
          | gzip --rsyncable > ${dumpDir}/tvtracktime.sql.gz.in-progress
        mv ${dumpDir}/tvtracktime.sql.gz.in-progress ${dumpDir}/tvtracktime.sql.gz

        if ! kopia repository status >/dev/null 2>&1; then
          kopia repository connect s3 ${repositoryArgs} \
            || kopia repository create s3 ${repositoryArgs}
        fi

        kopia policy set --global --compression=zstd --keep-latest=1 \
          --keep-hourly=0 --keep-daily=2 --keep-weekly=1 --keep-monthly=1 \
          --keep-annual=0

        kopia snapshot create ${lib.escapeShellArgs sources}

        notify up OK
      '';
    };

    timers.kopia-backup = {
      wantedBy = [ "timers.target" ];

      timerConfig = {
        OnCalendar = "*-*-* 04:00:00";
        Persistent = true;
      };
    };
  };
}
