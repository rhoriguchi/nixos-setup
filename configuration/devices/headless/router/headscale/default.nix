{
  config,
  lib,
  pkgs,
  secrets,
  ...
}:
let
  hostnames = lib.attrNames secrets.headscale.preAuthKeys;
  tailscaleIps = import ./ips.nix;

  unixEpoch = "1970-01-01 00:00:00.000000000+00:00";
  expiration = "2099-01-01 00:00:00.000000000+00:00";

  addApiKeySql = ''
    DELETE FROM api_keys;

    INSERT OR REPLACE INTO api_keys (
      id,
      created_at,
      expiration,
      hash,
      prefix
    ) VALUES (
      1,
      '${unixEpoch}',
      '${expiration}',
      X'${secrets.headscale.apiKey.hash}',
      '${secrets.headscale.apiKey.prefix}'
    );
  '';

  addUserSql = ''
    DELETE FROM users;

    ${lib.concatStringsSep "\n" (
      lib.imap1 (index: hostname: ''
        INSERT OR REPLACE INTO users (
          id,
          created_at,
          updated_at,
          name
        ) VALUES (
          ${toString index},
          '${unixEpoch}',
          '${expiration}',
          '${hostname}'
        );
      '') hostnames
    )}
  '';

  addPreAuthKeySql = ''
    DELETE FROM pre_auth_keys;

    ${lib.concatStringsSep "\n" (
      lib.imap1 (index: hostname: ''
        INSERT INTO pre_auth_keys (
          ID,
          USER_ID,
          created_at,
          expiration,
          key,
          tags,
          ephemeral,
          reusable
        ) VALUES (
          ${toString index},
          ${toString index},
          '${unixEpoch}',
          '${expiration}',
          '${secrets.headscale.preAuthKeys.${hostname}}',
          '[]',
          0,
          1
        );
      '') hostnames
    )}
  '';

  removeOldNodeSql = ''
    DELETE FROM nodes
    WHERE user_id > ${toString (lib.length hostnames)};

    DELETE
    FROM nodes
    WHERE id NOT IN
        (SELECT id
         FROM nodes AS n1
         WHERE n1.last_seen =
             (SELECT MAX(n2.last_seen)
              FROM nodes AS n2
              WHERE n2.user_id = n1.user_id));
  '';

  selectNodeDifferencesSql = lib.concatStringsSep "\nUNION ALL\n" (
    lib.imap1 (index: hostname: ''
      SELECT id,
             given_name,
             ipv4
      FROM nodes
      WHERE user_id = ${toString index}
        AND (given_name IS NOT '${lib.toLower hostname}'
             OR ipv4 IS NOT '${tailscaleIps.${hostname}}')
    '') hostnames
  );

  updateNodeSql = lib.concatStringsSep "\n" (
    lib.imap1 (index: hostname: ''
      UPDATE nodes
      SET given_name = '${lib.toLower hostname}',
          ipv4 = '${tailscaleIps.${hostname}}'
      WHERE user_id = ${toString index};
    '') hostnames
  );
in
{
  imports = [ ./headplane.nix ];

  services = {
    headscale = {
      enable = true;

      settings = {
        server_url = "https://headscale.00a.ch";

        prefixes = {
          allocation = "random";
          v4 = "100.123.123.0/24";
          v6 = "fd7a:115c:a1e0::/48";
        };

        dns = {
          magic_dns = true;
          base_domain = "tailnet";
          override_local_dns = false;
        };

        derp = {
          server = {
            enabled = true;

            stun_listen_addr = "0.0.0.0:3478";

            region_id = 999;
            region_code = "zrh";
            region_name = "Zurich";

            automatically_add_embedded_derp_region = true;
          };

          urls = [ ];
          auto_update_enabled = false;
        };
      };
    };

    infomaniak = {
      enable = true;

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
      hostnames = [
        "headscale.00a.ch"
      ];
    };

    nginx = {
      enable = true;

      virtualHosts."headscale.00a.ch" = {
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.headscale.port}";
          proxyWebsockets = true;

          extraConfig = ''
            proxy_buffering off;
          '';
        };
      };
    };
  };

  systemd.services = {
    headscale-setup = {
      enable = config.services.headscale.enable;

      after = [ config.systemd.services.headscale.name ];
      wants = [ config.systemd.services.headscale.name ];

      script = ''
        ${pkgs.sqlite-interactive}/bin/sqlite3 ${config.services.headscale.settings.database.sqlite.path} << EOF
          ${addApiKeySql}
          ${addUserSql}
          ${addPreAuthKeySql}
        EOF
      '';

      serviceConfig = {
        User = config.services.headscale.user;
        Group = config.services.headscale.group;
        Type = "oneshot";
      };
    };

    headscale-update-nodes = {
      enable = config.services.headscale.enable;

      after = [ config.systemd.services.headscale.name ];
      wants = [ config.systemd.services.headscale.name ];

      script = ''
        ${pkgs.sqlite-interactive}/bin/sqlite3 ${config.services.headscale.settings.database.sqlite.path} << EOF
          ${removeOldNodeSql}
        EOF

        differences=$(${pkgs.sqlite-interactive}/bin/sqlite3 -csv ${config.services.headscale.settings.database.sqlite.path} << EOF
          ${selectNodeDifferencesSql}
        EOF
        )

        if [ -n "$differences" ]; then
          echo "Updating nodes"

          ${pkgs.sqlite-interactive}/bin/sqlite3 ${config.services.headscale.settings.database.sqlite.path} << EOF
            ${updateNodeSql}
        EOF

          systemctl restart ${config.systemd.services.headscale.name}
        fi
      '';

      serviceConfig = {
        User = config.services.headscale.user;
        Group = config.services.headscale.group;
        Type = "oneshot";
      };

      startAt = "*:*:0/30";
    };
  };

  networking.firewall.allowedUDPPorts = [
    (lib.toIntBase10 (
      lib.last (lib.splitString ":" config.services.headscale.settings.derp.server.stun_listen_addr)
    ))
  ];
}
