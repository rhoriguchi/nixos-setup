{
  config,
  lib,
  pkgs,
  ...
}:
let
  backupDir = "/mnt/Data/Backup/${config.networking.hostName}";
in
{
  services = {
    borgmatic = {
      enable = true;

      settings = {
        keep_daily = 7;
        keep_weekly = 4;
        keep_monthly = 3;

        source_directories = [
          "/mnt/Data/Movies"
          "/mnt/Data/Series"
          "/var/cache/netdata"
          "/var/lib/${config.services.prometheus.stateDir}"
          "/var/lib/hass/backups"

          config.services.loki.dataDir
          config.services.minecraft-servers.dataDir
          config.services.plex.dataDir
          config.services.prowlarr.dataDir
          config.services.resilio.syncPath
          config.services.sonarr.dataDir
          config.services.tautulli.dataDir
        ];

        repositories = [
          {
            label = "local";
            path = backupDir;
          }
        ];

        hooks.postgresql_databases =
          let
            commands =
              lib.optionals config.security.sudo.enable [ "${config.security.sudo.package}/bin/sudo" ]
              ++ lib.optionals config.security.sudo-rs.enable [ "${config.security.sudo-rs.package}/bin/sudo" ]
              ++ lib.optionals config.security.doas.enable [ "${config.security.doas.package}/bin/doas" ];

            command = lib.findFirst (_: true) "${pkgs.sudo}/bin/sudo" commands;
          in
          lib.optional config.services.postgresql.enable {
            name = "all";
            format = "custom";
            psql_command = "${command} -u postgres ${config.services.postgresql.package}/bin/psql";
            pg_dump_command = "${command} -u postgres ${config.services.postgresql.package}/bin/pg_dump";
            pg_restore_command = "${command} -u postgres ${config.services.postgresql.package}/bin/pg_restore";
          };
      };
    };

    borg-exporter.repository = backupDir;
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
