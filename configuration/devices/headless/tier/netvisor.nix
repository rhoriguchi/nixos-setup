{
  config,
  pkgs,
  secrets,
  ...
}:
let
  # TODO fail2ban?
  # Nov 27 03:50:39 XXLPitu-Tier server[291929]: 2025-11-27T02:50:39.292916Z DEBUG netvisor::server::logging::subscriber: { id: c54d4e82-b221-4c9f-b378-300d9f34be7c, user_id: None, organization_id: None, operation: LoginFailed, timestamp: 2025-11-27 02:50:39.292881654 UTC, ip_address: 127.0.0.1, user_agent: Mozilla/5.0 (X11; Linux x86_64; rv:145.0) Gecko/20100101 Firefox/145.0, metadata: {"email":"admin@00a.ch","method":"password"}, authentication: Anonymous }
  # Nov 27 03:50:39 XXLPitu-Tier server[291929]: 2025-11-27T02:50:39.292927Z ERROR netvisor::server::shared::types::api: Internal error: Invalid username or password

  email = "admin@00a.ch";

  networkName = "Home";

  updateDefaultNetworkSql = ''
    DO $$
      DECLARE
        rec RECORD;
        old_id uuid;
        new_id uuid := '${config.services.networkTopology.networkId}';
      BEGIN
        SELECT id
        INTO old_id
        FROM networks
        WHERE name = '${networkName}';

        IF old_id IS NOT NULL THEN
          FOR rec IN
            SELECT tc.table_schema,
                   tc.table_name,
                   tc.constraint_name,
                   kcu.column_name
            FROM information_schema.table_constraints AS tc
            JOIN information_schema.key_column_usage AS kcu ON tc.constraint_name = kcu.constraint_name
            AND tc.table_schema = kcu.table_schema
            JOIN information_schema.constraint_column_usage AS ccu ON ccu.constraint_name = tc.constraint_name
            AND ccu.table_schema = tc.table_schema
            WHERE tc.constraint_type = 'FOREIGN KEY'
              AND ccu.table_name = 'networks'
              AND ccu.column_name = 'id'
          LOOP
            EXECUTE format(
                'ALTER TABLE %I.%I DROP CONSTRAINT %I',
                rec.table_schema,
                rec.table_name,
                rec.constraint_name
            );

            EXECUTE format(
              'ALTER TABLE %I.%I ADD CONSTRAINT %I FOREIGN KEY (%I) REFERENCES networks(id) ON DELETE CASCADE ON UPDATE CASCADE',
              rec.table_schema,
              rec.table_name,
              rec.constraint_name,
              rec.column_name
            );
          END LOOP;

          UPDATE networks
          SET id = new_id
          WHERE id = old_id;
        ELSE
          RAISE INFO 'Skipping update';
        END IF;
    END $$;
  '';

  addApiKeySql = ''
    INSERT INTO api_keys (
      id,
      key,
      network_id,
      name,
      is_enabled
    ) VALUES (
      '8e73c8f5-343e-4ed8-9af4-c95d566d395c',
      '${secrets.netvisor.apiKey}',
      '${config.services.networkTopology.networkId}',
      'Remote Daemon API Key',
      true
    )
    ON CONFLICT (id) DO NOTHING;
  '';
in
{
  services = {
    networkTopology.isServer = true;

    # Feature request

    # - When no user exists allow registration even if `--disable-registration` set
    # - Add a config option / flag so you can pass a file path for `oicd.toml`
    # - Option to disable auth and just log in to specified user

    netvisor = {
      server = {
        enable = true;

        publicUrl = "https://netvisor.00a.ch";
        hostname = "netvisor.00a.ch";

        useSecureSessionCookies = true;
        # TODO with this setup does not work
        # disableRegistration = true;

        nginx = {
          enableACME = true;
          forceSSL = true;
        };
      };
    };

    infomaniak = {
      enable = true;

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
      hostnames = [
        "netvisor.00a.ch"
      ];
    };
  };

  systemd.services.netvisor-server-setup = {
    enable = config.services.netvisor.server.enable;

    after = [ config.systemd.services.netvisor-server.name ];
    wants = [ config.systemd.services.netvisor-server.name ];

    script = ''
      user=$(${config.services.postgresql.package}/bin/psql ${config.services.netvisor.server.database.name} -t << 'EOF'
        SELECT email
        FROM users
        WHERE email = '${email}';
      EOF
      )

      if [[ "$(echo "$user" | xargs)" != '${email}' ]]; then
        echo "Adding user ${email}"

        COOKIE_JAR="$(mktemp)"

        ${pkgs.curl}/bin/curl -s 'https://netvisor.00a.ch/api/auth/register' \
          -X POST \
          -H "Content-Type: application/json" \
          -c "$COOKIE_JAR" \
          --data-raw '{"email":"${email}","password":"${secrets.netvisor.users.${email}}"}'

        ${pkgs.curl}/bin/curl -s 'https://netvisor.00a.ch/api/onboarding' \
          -X POST \
          -H "Content-Type: application/json" \
          -b "$COOKIE_JAR" \
          --data-raw '{"organization_name":"00a.ch","network_name":"${networkName}","populate_seed_data":false}'

        rm -f "$COOKIE_JAR"
      fi

      ${config.services.postgresql.package}/bin/psql ${config.services.netvisor.server.database.name} << 'EOF'
        ${updateDefaultNetworkSql}
        ${addApiKeySql}
      EOF
    '';

    serviceConfig = {
      User = config.services.netvisor.user;
      Group = config.services.netvisor.group;
      Type = "oneshot";
    };
  };

  networking.firewall.interfaces.${config.services.tailscale.interfaceName}.allowedTCPPorts = [
    config.services.netvisor.server.port
  ];
}
