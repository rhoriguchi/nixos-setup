{
  config,
  lib,
  libCustom,
  pkgs,
  ...
}:
let
  tailscaleIps = import (
    libCustom.relativeToRoot "configuration/devices/headless/nelliel/headscale/ips.nix"
  );

  getHostId = hostname: lib.last (lib.splitString "." tailscaleIps.${hostname}.ip);

  monitorIds = {
    borgmaticBackup = 256;
    borgmaticBackupRemote = 257;
    tvtracktime = 258;
  };

  tailscaleMonitorHostnames = lib.pipe tailscaleIps [
    (lib.filterAttrs (_: value: value.monitoring or true))
    lib.attrNames

    (hostnames: lib.subtractLists [ config.networking.hostName ] hostnames)
  ];

  monitorIdList =
    map (hostname: lib.toInt (getHostId hostname)) tailscaleMonitorHostnames
    ++ lib.attrValues monitorIds;

  updateSettings =
    let
      updateSetting = key: value: ''
        INSERT OR REPLACE INTO setting (
          id,
          key,
          value,
          type
        )
        VALUES (
          (SELECT id FROM setting WHERE KEY = '${key}'),
          '${key}',
          '${value}',
          'general'
        );
      '';
    in
    ''
      ${updateSetting "checkUpdate" "false"}
      ${updateSetting "trustProxy" "true"}
      ${updateSetting "disableAuth" "true"}
    '';

  addUser = ''
    DELETE FROM user;

    INSERT INTO user (
      id,
      username,
      password
    )
    VALUES (
      1,
      'admin',
      '$2a$10$zpX09f2fmv8sinFhwkC61.KoA.n9ktdO6hgrDPpNduEUMwt2FS7XK'
    );
  '';

  historyTables = [
    "heartbeat"
    "stat_minutely"
    "stat_hourly"
    "stat_daily"
    "monitor_tls_info"
    "notification_sent_history"
  ];

  configTables = [
    "monitor_group"
    "monitor_maintenance"
    "monitor_tag"
  ];

  clearChangedHistory =
    {
      id,
      type,
      identity,
    }:
    lib.concatMapStringsSep "\n" (table: ''
      DELETE FROM ${table}
      WHERE monitor_id = ${toString id}
        AND NOT EXISTS (
          SELECT 1 FROM monitor
          WHERE id = ${toString id}
            AND type IS '${type}'
            ${lib.concatStringsSep "\n      " (
              lib.mapAttrsToList (column: value: "AND ${column} IS '${value}'") identity
            )}
        );
    '') historyTables;

  addMonitors =
    let
      insertBorgmaticMonitor =
        {
          id,
          name,
          pushToken,
        }:
        ''
          INSERT OR REPLACE INTO monitor (
            id,
            name,
            user_id,
            type,
            push_token,
            interval,
            retry_interval,
            resend_interval
          )
          VALUES (
            '${toString id}',
            '${name}',
            1,
            'push',
            '${pushToken}',
            ${toString ((60 * 60 * 24) + (60 * 60 * 6))},
            0,
            1
          );
        '';

      insertTvtracktimeMonitor = ''
        INSERT OR REPLACE INTO monitor (
          id,
          name,
          user_id,
          type,
          url,
          interval,
          maxretries,
          retry_interval
        )
        VALUES (
          '${toString monitorIds.tvtracktime}',
          'tvtracktime.com',
          1,
          'http',
          'https://tvtracktime.com',
          60,
          3,
          20
        );
      '';

      insertTailscaleMonitor = hostname: ''
        ${clearChangedHistory {
          id = getHostId hostname;
          type = "tailscale-ping";
          identity.hostname = hostname;
        }}
        INSERT OR REPLACE INTO monitor (
          id,
          name,
          user_id,
          type,
          hostname,
          interval,
          maxretries,
          retry_interval
        )
        VALUES (
          ${getHostId hostname},
          '${hostname}',
          1,
          'tailscale-ping',
          '${hostname}',
          60,
          5,
          60
        );
      '';

      insertTailscaleMonitors = lib.pipe tailscaleMonitorHostnames [
        (map insertTailscaleMonitor)

        (lib.concatStringsSep "\n")
      ];
    in
    ''
      ${clearChangedHistory {
        id = monitorIds.borgmaticBackup;
        type = "push";
        identity.push_token = "$pushToken";
      }}
      ${insertBorgmaticMonitor {
        id = monitorIds.borgmaticBackup;
        name = "Borgmatic backup";
        pushToken = "$pushToken";
      }}
      ${clearChangedHistory {
        id = monitorIds.borgmaticBackupRemote;
        type = "push";
        identity.push_token = "$pushTokenRemote";
      }}
      ${insertBorgmaticMonitor {
        id = monitorIds.borgmaticBackupRemote;
        name = "Borgmatic backup remote";
        pushToken = "$pushTokenRemote";
      }}
      ${clearChangedHistory {
        id = monitorIds.tvtracktime;
        type = "http";
        identity.url = "https://tvtracktime.com";
      }}
      ${insertTvtracktimeMonitor}
      ${insertTailscaleMonitors}

      DELETE FROM monitor WHERE id NOT IN (${lib.concatMapStringsSep ", " toString monitorIdList});

      ${lib.concatMapStringsSep "\n" (table: ''
        DELETE FROM ${table} WHERE monitor_id NOT IN (SELECT id FROM monitor);
      '') (historyTables ++ configTables)}
    '';

  addNotifications =
    let
      insertDiscordNotification = ''
        INSERT INTO notification (
          id,
          name,
          user_id,
          active,
          is_default,
          config
        )
        VALUES (
          1,
          'Discord',
          1,
          1,
          0,
          '$discordNotificationConfig'
        );
      '';

      insertMonitorNotification = monitorId: ''
        INSERT INTO monitor_notification (
          notification_id,
          monitor_id
        )
        VALUES (
          1,
          ${toString monitorId}
        );
      '';
    in
    ''
      DELETE FROM notification;

      ${insertDiscordNotification}

      DELETE FROM monitor_notification;

      ${insertMonitorNotification monitorIds.borgmaticBackup}
      ${insertMonitorNotification monitorIds.borgmaticBackupRemote}
      ${insertMonitorNotification monitorIds.tvtracktime}
    '';
in
{
  sops = {
    secrets = {
      "services/uptime-kuma/discordWebhookUrl" = { };
      "services/uptime-kuma/pushTokens/borgmaticBackup".restartUnits = [
        config.systemd.services.uptime-kuma-setup.name
      ];
      "services/uptime-kuma/pushTokens/borgmaticBackupRemote".restartUnits = [
        config.systemd.services.uptime-kuma-setup.name
      ];
    };

    templates."services.uptime-kuma.discordNotificationConfig" = {
      content = lib.toJSON {
        name = "Discord";
        type = "discord";
        isDefault = false;
        applyExisting = false;
        discordWebhookUrl = config.sops.placeholder."services/uptime-kuma/discordWebhookUrl";
      };

      restartUnits = [ config.systemd.services.uptime-kuma-setup.name ];
    };
  };

  assertions = [
    {
      assertion = lib.length (lib.unique monitorIdList) == lib.length monitorIdList;
      message = "uptime-kuma monitor ids must be unique, got ${
        lib.concatMapStringsSep ", " toString monitorIdList
      }";
    }
  ];

  services = {
    uptime-kuma = {
      enable = true;

      package = pkgs.symlinkJoin {
        inherit (pkgs.uptime-kuma) name pname version;
        paths = [ pkgs.uptime-kuma ];

        nativeBuildInputs = [ pkgs.makeWrapper ];

        postBuild = ''
          wrapProgram $out/bin/uptime-kuma-server \
            --prefix PATH : ${
              lib.makeBinPath [
                config.services.tailscale.package
                pkgs.gamedig
              ]
            }
        '';
      };

      settings.PORT = "3002";
    };

    infomaniak = {
      enable = true;

      hostnames = [ "uptime-kuma.00a.ch" ];
    };

    nginx = {
      enable = true;

      virtualHosts."uptime-kuma.00a.ch" = {
        enableACME = true;
        forceSSL = true;

        extraConfig = ''
          include /run/nginx-authelia/location.conf;
        '';

        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:${toString config.services.uptime-kuma.settings.PORT}";

            proxyWebsockets = true;

            extraConfig = ''
              include /run/nginx-authelia/auth.conf;

              proxy_buffering off;
            '';
          };

          "/api/push".proxyPass = "http://127.0.0.1:${toString config.services.uptime-kuma.settings.PORT}";
        };
      };
    };
  };

  systemd.services.uptime-kuma-setup = {
    enable = config.services.uptime-kuma.enable;

    wants = [ config.systemd.services.uptime-kuma.name ];
    after = [ config.systemd.services.uptime-kuma.name ];
    wantedBy = [ "multi-user.target" ];

    script = ''
      dbFile="${config.services.uptime-kuma.settings.DATA_DIR}kuma.db"
      if [ -f "$dbFile" ]; then
        pushToken="$(cat ${config.sops.secrets."services/uptime-kuma/pushTokens/borgmaticBackup".path})"
        pushTokenRemote="$(cat ${
          config.sops.secrets."services/uptime-kuma/pushTokens/borgmaticBackupRemote".path
        })"
        discordNotificationConfig="$(cat ${
          config.sops.templates."services.uptime-kuma.discordNotificationConfig".path
        })"

        ${pkgs.sqlite-interactive}/bin/sqlite3 "$dbFile" <<'EOF'
          ${updateSettings}
          ${addUser}
      EOF

        ${pkgs.sqlite-interactive}/bin/sqlite3 "$dbFile" <<EOF
          ${addMonitors}
      EOF

        ${pkgs.sqlite-interactive}/bin/sqlite3 "$dbFile" <<EOF
          ${addNotifications}
      EOF

        echo 'Restarting ${config.systemd.services.uptime-kuma.name}'
        systemctl restart ${config.systemd.services.uptime-kuma.name}
      fi
    '';

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };
}
