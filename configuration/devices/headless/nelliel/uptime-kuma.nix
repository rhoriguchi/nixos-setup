{
  config,
  lib,
  libCustom,
  pkgs,
  secrets,
  ...
}:
let
  tailscaleIps = import (
    libCustom.relativeToRoot "configuration/devices/headless/nelliel/headscale/ips.nix"
  );
  filteredTailscaleHostnames = lib.filter (
    hostname:
    !(lib.elem hostname [
      config.networking.hostName
      "headplane-agent"
      "XXLPitu-Aizen"
      "XXLPitu-Nnoitra"
    ])
  ) (lib.attrNames tailscaleIps);

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

  addMonitors =
    let
      addTailscaleMonitor = hostname: ''
        INSERT INTO monitor (
          name,
          user_id,
          type,
          hostname,
          interval,
          maxretries,
          retry_interval
        )
        VALUES (
          '${hostname}',
          1,
          'tailscale-ping',
          '${hostname}',
          60,
          5,
          60
        );
      '';
    in
    ''
      DELETE FROM monitor;

      INSERT INTO monitor (
        id,
        name,
        user_id,
        type,
        game,
        hostname,
        port,
        interval,
        retry_interval
      )
      VALUES (
        1,
        'Minecraft',
        1,
        'gamedig',
        'minecraft',
        'minecraft.00a.ch',
        25565,
        15,
        15
      );

      INSERT INTO monitor (
        id,
        name,
        user_id,
        type,
        push_token,
        interval,
        retry_interval
      )
      VALUES (
        '2',
        'Borgmatic backup',
        1,
        'push',
        '${secrets.uptime-kuma.pushTokens.borgmaticBackup}',
        ${toString ((60 * 60 * 24) + (60 * 60 * 6))},
        0
      );

      INSERT INTO monitor (
        name,
        user_id,
        type,
        hostname,
        interval,
        retry_interval
      )
      VALUES (
        '${config.networking.hostName}',
        1,
        'ping',
        '${config.networking.hostName}',
        60,
        60
      );

      ${lib.concatStringsSep "\n" (
        map (hostname: addTailscaleMonitor hostname) filteredTailscaleHostnames
      )}
    '';

  addNotification =
    let
      addMonitorNotification = monitorId: ''
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
        '${
          builtins.toJSON {
            name = "Discord";
            type = "discord";
            isDefault = false;
            applyExisting = false;
            inherit (secrets.uptime-kuma) discordWebhookUrl;
          }
        }'
      );

      DELETE FROM monitor_notification;

      ${addMonitorNotification 1}
      ${addMonitorNotification 2}
    '';
in
{
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

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
      hostnames = [ "uptime-kuma.00a.ch" ];
    };

    nginx = {
      enable = true;

      virtualHosts."uptime-kuma.00a.ch" = {
        enableACME = true;
        acmeRoot = null;
        forceSSL = true;

        extraConfig = ''
          include /run/nginx-authelia/location.conf;
        '';

        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:${toString config.services.uptime-kuma.settings.PORT}";

            extraConfig = ''
              include /run/nginx-authelia/auth.conf;
            '';
          };

          "/api/push".proxyPass = "http://127.0.0.1:${toString config.services.uptime-kuma.settings.PORT}";
        };
      };
    };
  };

  systemd.services.uptime-kuma-setup = {
    enable = config.services.uptime-kuma.enable;

    after = [ config.systemd.services.uptime-kuma.name ];
    wants = [ config.systemd.services.uptime-kuma.name ];

    script = ''
      dbFile="${config.services.uptime-kuma.settings.DATA_DIR}kuma.db"
      if [ -f "$dbFile" ]; then
        ${pkgs.sqlite-interactive}/bin/sqlite3 "$dbFile" << 'EOF'
          ${updateSettings}
          ${addUser}
          ${addMonitors}
          ${addNotification}
        EOF

        echo 'Restarting ${config.systemd.services.uptime-kuma.name}'
        systemctl restart ${config.systemd.services.uptime-kuma.name}
      fi
    '';

    serviceConfig.Type = "oneshot";
  };
}
