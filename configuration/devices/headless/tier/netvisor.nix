{
  config,
  lib,
  secrets,
  ...
}:
let
  networkId = "92e3eb07-8cd7-4c8b-bfa4-3e67c109eebd";

  updateDefaultNetworkSql = ''
    DO $$
      DECLARE
        rec RECORD;
        old_id uuid;
        new_id uuid := '${networkId}';
      BEGIN
        SELECT id
        INTO old_id
        FROM networks
        WHERE name = 'My Network';

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
          SET id = new_id,
            name = 'Home'
          WHERE id = old_id;
        ELSE
          RAISE INFO 'Skipping "My Network" update';
        END IF;
    END $$;
  '';

  deleteSeedDataSql = ''
    DELETE FROM hosts
    WHERE name IN ('${
      lib.concatStringsSep "', '" [
        "Cloudflare DNS"
        "Google.com"
        "Mobile Device"
      ]
    }');

    DELETE FROM subnets
    WHERE name IN ('${
      lib.concatStringsSep "', '" [
        "Internet"
        "Remote Network"
      ]
    }');
  '';

  # Update user PW or run some curl command?
  # addUserSql = ''
  #   INSERT INTO users (
  #     id,
  #     created_at,
  #     updated_at,
  #     email
  #   ) VALUES (
  #     '${userId}',
  #     '${unixEpoch}',
  #     '${unixEpoch}',
  #     'admin@00a.ch'
  #   )
  #   ON CONFLICT (id) DO NOTHING;
  # '';

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
      '${networkId}',
      'Remote Daemon API Key',
      true
    )
    ON CONFLICT (id) DO NOTHING;
  '';
in
{
  services = {
    netvisor = {
      server = {
        enable = true;

        publicHostname = "netvisor.00a.ch";
        publicPort = 443;

        # TODO uncomment
        # disableRegistration = true;

        nginx = {
          enableACME = true;
          forceSSL = true;
        };
      };

      # TODO remove
      daemon = {
        serverTarget = lib.mkForce "http://127.0.0.1";
        daemonApiKey = lib.mkForce null;
        networkId = lib.mkForce null;
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

    # Workaround for the nginx attributes since lib.mkMerge fails
    nginx.virtualHosts."${config.services.netvisor.server.publicHostname}".locations."/" = {
      basicAuth = secrets.nginx.basicAuth."netvisor.00a.ch";

      extraConfig = ''
        satisfy any;

        allow 192.168.2.0/24;
        deny all;
      '';
    };
  };

  systemd.services.netvisor-server-setup = {
    enable = config.services.netvisor.server.enable;

    after = [ config.systemd.services.netvisor-server.name ];
    wants = [ config.systemd.services.netvisor-server.name ];

    script = ''
      ${config.services.postgresql.package}/bin/psql ${config.services.netvisor.server.database.name} << 'EOF'
        ${updateDefaultNetworkSql}
        ${deleteSeedDataSql}
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
