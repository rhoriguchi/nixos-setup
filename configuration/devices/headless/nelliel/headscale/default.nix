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

  parseKey =
    key:
    let
      rawKey = lib.replaceStrings [ "hskey-api-" "hskey-auth-" ] [ "" "" ] key;
      prefix = lib.substring 0 12 rawKey;
    in
    {
      inherit prefix;
      secret = lib.replaceStrings [ "${prefix}-" ] [ "" ] rawKey;
    };

  unixEpoch = "1970-01-01 00:00:00.000000000+00:00";
  expiration = "2099-01-01 00:00:00.000000000+00:00";

  addApiKey =
    let
      key = parseKey secrets.headscale.apiKey;
    in
    ''
      apiKey="$(${pkgs.apacheHttpd}/bin/htpasswd -bnBC 10 "" "${key.secret}" | cut -d: -f2)"

      ${pkgs.sqlite-interactive}/bin/sqlite3 ${config.services.headscale.settings.database.sqlite.path} << EOF
        DELETE FROM api_keys;

        INSERT INTO api_keys (
          id,
          created_at,
          expiration,
          prefix,
          hash
        ) VALUES (
          1,
          '${unixEpoch}',
          '${expiration}',
          '${key.prefix}',
          '$apiKey'
        );
      EOF
    '';

  addPreAuthKeys = ''
    ${pkgs.sqlite-interactive}/bin/sqlite3 ${config.services.headscale.settings.database.sqlite.path} << 'EOF'
      DELETE FROM pre_auth_keys;
    EOF

    ${lib.concatStringsSep "\n" (
      lib.imap1 (
        index: hostname:
        let
          preAuthKey = secrets.headscale.preAuthKeys.${hostname};

          key = parseKey preAuthKey.key;
          tags = (preAuthKey.tags or [ ]) ++ [ hostname ];
        in
        ''
          preAuthKey="$(${pkgs.apacheHttpd}/bin/htpasswd -bnBC 10 "" "${key.secret}" | cut -d: -f2)"

          ${pkgs.sqlite-interactive}/bin/sqlite3 ${config.services.headscale.settings.database.sqlite.path} << EOF
            INSERT INTO pre_auth_keys (
              id,
              created_at,
              expiration,
              tags,
              ephemeral,
              reusable,
              prefix,
              hash
            ) VALUES (
              ${toString index},
              '${unixEpoch}',
              '${expiration}',
              '[${lib.concatStringsSep "," (map (tag: ''"tag:${tag}"'') tags)}]',
              0,
              1,
              '${key.prefix}',
              '$preAuthKey'
            );
          EOF
        ''
      ) hostnames
    )}
  '';

  deleteNodesSql = ''
    DELETE FROM nodes
    WHERE auth_key_id > ${toString (lib.length hostnames)};

    DELETE
    FROM nodes
    WHERE id NOT IN
        (SELECT id
         FROM nodes AS n1
         WHERE n1.last_seen =
             (SELECT MAX(n2.last_seen)
              FROM nodes AS n2
              WHERE n2.auth_key_id = n1.auth_key_id));
  '';

  updateNodesSql = lib.concatStringsSep "\n" (
    lib.imap1 (index: hostname: ''
      UPDATE nodes
      SET given_name = '${lib.toLower hostname}',
          ipv4 = '${tailscaleIps.${hostname}}',
          tags = (SELECT tags FROM pre_auth_keys WHERE id = ${toString index})
      WHERE auth_key_id = ${toString index};
    '') hostnames
  );
in
{
  imports = [
    ./headplane.nix
  ];

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

        policy.path = (pkgs.formats.json { }).generate "policy.json" {
          tagOwners = {
            "tag:headful" = [ ];
            "tag:headless" = [ ];
          };

          acls = [
            {
              action = "accept";
              src = [ "tag:headful" ];
              dst = [ "tag:headless:*" ];
            }
            {
              action = "accept";
              src = [ "tag:headless" ];
              dst = [ "tag:headless:*" ];
            }
          ];
        };

        derp = {
          server.enabled = false;

          paths = [
            # `(pkgs.formats.yaml { }).generate` does not support keys as number
            (pkgs.writeText "derpmap.yaml" ''
              regions:
                998:
                  regionid: 998
                  regioncode: nbg
                  regionname: Nuremberg

                  nodes:
                    - name: Tailscale Embedded DERP - Nuremberg
                      regionid: 998
                      hostname: derp-nbg.00a.ch
                      canport80: true

                999:
                  regionid: 999
                  regioncode: zrh
                  regionname: Zurich

                  nodes:
                    - name: Tailscale Embedded DERP - Zurich
                      regionid: 999
                      hostname: derp-zrh.00a.ch
                      canport80: true
            '')
          ];

          urls = [ ];
          auto_update_enabled = false;
        };

        logtail.enabled = false;
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
        ${addApiKey}
        ${addPreAuthKeys}
      '';

      serviceConfig.Type = "oneshot";
    };

    headscale-cleanup-nodes = {
      enable = config.services.headscale.enable;

      after = [ config.systemd.services.headscale.name ];
      wants = [ config.systemd.services.headscale.name ];

      script = ''
        deleted_nodes=$(${pkgs.sqlite-interactive}/bin/sqlite3 ${config.services.headscale.settings.database.sqlite.path} << 'EOF'
          BEGIN;

          ${deleteNodesSql}
          SELECT changes();

          COMMIT;
        EOF
        )

        updated_nodes=$(${pkgs.sqlite-interactive}/bin/sqlite3 -csv ${config.services.headscale.settings.database.sqlite.path} << 'EOF'
          BEGIN;

          ${updateNodesSql}
          SELECT changes();

          COMMIT;
        EOF
        )

        if [ "$deleted_nodes" -gt 0 ] || [ "$updated_nodes" -gt 0 ]; then
          echo 'Restarting ${config.systemd.services.headscale.name}'
          systemctl restart ${config.systemd.services.headscale.name}
        fi
      '';

      serviceConfig.Type = "oneshot";

      startAt = "*:*:0/30";
    };
  };
}
