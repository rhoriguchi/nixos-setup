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

  getHostId = hostname: lib.last (lib.splitString "." tailscaleIps.${hostname});

  parseKey =
    key:
    lib.pipe key [
      (lib.replaceStrings [ "hskey-api-" "hskey-auth-" ] [ "" "" ])

      (
        rawKey:
        let
          prefix = lib.substring 0 12 rawKey;
        in
        {
          inherit prefix;
          secret = lib.replaceStrings [ "${prefix}-" ] [ "" ] rawKey;
        }
      )
    ];

  unixEpoch = "1970-01-01 00:00:00.000000000+00:00";
  expiration = "2099-01-01 00:00:00.000000000+00:00";

  addApiKey =
    let
      key = parseKey secrets.headscale.apiKey;
    in
    ''
      apiKey="$(${pkgs.apacheHttpd}/bin/htpasswd -bnBC 10 "" "${key.secret}" | cut -d: -f2)"

      ${pkgs.sqlite-interactive}/bin/sqlite3 "${config.services.headscale.settings.database.sqlite.path}" <<EOF
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
    ${pkgs.sqlite-interactive}/bin/sqlite3 "${config.services.headscale.settings.database.sqlite.path}" <<'EOF'
      DELETE FROM pre_auth_keys;
    EOF

    ${lib.pipe hostnames [
      (map (
        hostname:
        let
          preAuthKey = secrets.headscale.preAuthKeys.${hostname};
          key = parseKey preAuthKey.key;
          tags = (preAuthKey.tags or [ ]) ++ [ hostname ];
        in
        ''
          preAuthKey="$(${pkgs.apacheHttpd}/bin/htpasswd -bnBC 10 "" "${key.secret}" | cut -d: -f2)"

          ${pkgs.sqlite-interactive}/bin/sqlite3 "${config.services.headscale.settings.database.sqlite.path}" <<EOF
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
              ${getHostId hostname},
              '${unixEpoch}',
              '${expiration}',
              '[${
                lib.pipe tags [
                  (map (tag: ''"tag:${lib.toLower tag}"''))
                  (lib.concatStringsSep ",")
                ]
              }]',
              0,
              1,
              '${key.prefix}',
              '$preAuthKey'
            );
          EOF
        ''
      ))

      (lib.concatStringsSep "\n")
    ]}
  '';

  deleteNodesSql = ''
    DELETE
    FROM nodes
    WHERE auth_key_id NOT IN (${
      lib.concatStringsSep "," (map (hostname: getHostId hostname) hostnames)
    });

    DELETE
    FROM nodes
    WHERE id NOT IN
      (SELECT id
      FROM nodes
      GROUP BY auth_key_id
      HAVING last_seen = MAX(last_seen));
  '';

  updateNodesSql = lib.pipe hostnames [
    (map (hostname: ''
      UPDATE nodes
      SET given_name = '${lib.toLower hostname}',
          ipv4 = '${tailscaleIps.${hostname}}',
          tags = (SELECT tags FROM pre_auth_keys WHERE id = ${getHostId hostname})
      WHERE auth_key_id = ${getHostId hostname};
    ''))

    (lib.concatStringsSep "\n")
  ];
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

        policy.path = pkgs.writers.writeJSON "policy.json" {
          tagOwners = {
            "tag:admin" = [ ];
            "tag:exit-node" = [ ];
            "tag:headful" = [ ];
            "tag:headless" = [ ];
          };

          autoApprovers.exitNode = [ "tag:exit-node" ];

          grants = [
            {
              src = [ "tag:admin" ];
              dst = [ "tag:headless" ];
              ip = [
                "tcp:22" # SSH
              ];
            }

            {
              src = [ "tag:headful" ];
              dst = [ "tag:headful" ];
              ip = [
                "tcp:53317" # LocalSend
              ];
            }
            {
              src = [ "tag:headful" ];
              dst = [ "tag:headless" ];
              ip = [
                "tcp:21027" # Syncthing
                "tcp:22000" # Syncthing
              ];
            }
            {
              src = [ "tag:headful" ];
              dst = [ "autogroup:internet" ];
              ip = [ "*" ];
            }

            {
              src = [ "tag:headless" ];
              dst = [ "tag:headless" ];
              ip = [ "*" ];
            }
          ];
        };

        derp = {
          server.enabled = false;

          paths = [
            # `pkgs.writers.writeYAML` does not support keys as number
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
        acmeRoot = null;
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

      wants = [ config.systemd.services.headscale.name ];
      after = [ config.systemd.services.headscale.name ];
      wantedBy = [ "multi-user.target" ];

      script = ''
        ${addApiKey}
        ${addPreAuthKeys}
      '';

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
    };

    headscale-cleanup-nodes = {
      enable = config.services.headscale.enable;

      after = [ config.systemd.services.headscale.name ];

      script = ''
        deleted_nodes=$(${pkgs.sqlite-interactive}/bin/sqlite3 "${config.services.headscale.settings.database.sqlite.path}" <<'EOF'
          BEGIN;

          ${deleteNodesSql}
          SELECT changes();

          COMMIT;
        EOF
        )

        updated_nodes=$(${pkgs.sqlite-interactive}/bin/sqlite3 -csv "${config.services.headscale.settings.database.sqlite.path}" <<'EOF'
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

      startAt = "*:0/5:0";
    };
  };
}
