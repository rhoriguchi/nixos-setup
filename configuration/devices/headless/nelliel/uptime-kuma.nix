{
  config,
  lib,
  pkgs,
  secrets,
  ...
}:
let
  tailscaleIps = import (
    lib.custom.relativeToRoot "configuration/devices/headless/nelliel/headscale/ips.nix"
  );
  filteredTailscaleHostnames = lib.filter (
    hostname:
    !(lib.elem hostname [
      config.networking.hostName
      "headplane-agent"
      "Ryan-Laptop"
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
      addMonitor = id: hostname: ''
        INSERT INTO monitor (
          id,
          name,
          user_id,
          type,
          hostname,
          interval,
          retry_interval
        )
        VALUES (
          ${toString id},
          '${hostname}',
          1,
          'tailscale-ping',
          '${hostname}',
          60,
          60
        );
      '';
    in
    ''
      DELETE FROM monitor;

      ${lib.concatStringsSep "\n" (
        lib.imap1 (index: hostname: addMonitor index hostname) filteredTailscaleHostnames
      )}
    '';
in
{
  services = {
    uptime-kuma = {
      enable = true;

      package = pkgs.symlinkJoin {
        inherit (pkgs.uptime-kuma) name;
        paths = [ pkgs.uptime-kuma ];

        nativeBuildInputs = [ pkgs.makeWrapper ];

        postBuild = ''
          wrapProgram $out/bin/uptime-kuma-server \
            --prefix PATH : ${lib.makeBinPath [ config.services.tailscale.package ]}
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
        forceSSL = true;

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.uptime-kuma.settings.PORT}";
          basicAuth = secrets.nginx.basicAuth."uptime-kuma.00a.ch";

          extraConfig = ''
            satisfy any;

            allow 192.168.2.0/24;
            deny all;
          '';
        };
      };
    };
  };

  systemd.services.uptime-kuma-setup = {
    enable = config.services.uptime-kuma.enable;

    after = [ config.systemd.services.uptime-kuma.name ];
    wants = [ config.systemd.services.uptime-kuma.name ];

    script = ''
      ${pkgs.sqlite-interactive}/bin/sqlite3 ${config.services.uptime-kuma.settings.DATA_DIR}kuma.db << EOF
        ${updateSettings}
        ${addUser}
        ${addMonitors}
      EOF
    '';

    serviceConfig.Type = "oneshot";
  };
}
