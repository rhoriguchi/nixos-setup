{
  config,
  lib,
  pkgs,
  secrets,
  ...
}:
let
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
    )
    VALUES (
      1,
      '${unixEpoch}',
      '${expiration}',
      X'${secrets.headscale.apiKey.hash}',
      '${secrets.headscale.apiKey.prefix}'
    );
  '';

  addUserSql = ''
    DELETE FROM users;

    INSERT OR REPLACE INTO users (
      'id',
      'created_at',
      'updated_at',
      'name'
    ) VALUES (
      1,
      '${unixEpoch}',
      '${expiration}',
      'default'
    );
  '';
in
{
  services = {
    # TODO implement
    # https://github.com/JayRovacsek/nix-config/blob/27ef4a04a615a3d61f93abd92902fb3cb39f3838/options/modules/headscale/default.nix#L49-L63

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
          # TODO should be enabled by default?
          # magic_dns = true;
          base_domain = "tailnet";
          override_local_dns = false;
        };

        # TODO commented
        # oidc:
        #   issuer: "https://sso.example.com"
        #   client_id: "headscale"
        #   client_secret: "generated-secret"
        #   expiry: 30d   # Use 0 to disable node expiration

        derp = {
          auto_update_enabled = false;

          server = {
            enable = true;
            stun_listen_addr = "0.0.0.0:3478";
          };
        };
      };
    };

    headplane = {
      enable = true;

      settings = {
        server = {
          host = "127.0.0.1";
          port = 3001;

          cookie_secret = secrets.headplane.cookie_secret;
          cookie_secure = true;
        };

        headscale = {
          url = "http://127.0.0.1:${toString config.services.headscale.port}";
          public_url = "https://headscale.00a.ch";

          config_path = (pkgs.formats.yaml { }).generate "headscale.yml" (
            lib.recursiveUpdate config.services.headscale.settings {
              acme_email = "/dev/null";
              tls_cert_path = "/dev/null";
              tls_key_path = "/dev/null";
              policy.path = "/dev/null";
              oidc.client_secret_path = "/dev/null";
            }
          );

          config_strict = true;
        };

        integration.proc.enabled = true;
      };

      agent.enable = false;
    };

    infomaniak = {
      enable = true;

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
      hostnames = [
        "headplane.00a.ch"
        "headscale.00a.ch"
      ];
    };

    nginx = {
      enable = true;

      virtualHosts = {
        "headplane.00a.ch" = {
          enableACME = true;
          forceSSL = true;

          locations = {
            "/".extraConfig = ''
              rewrite ^/$ /admin last;
            '';

            "/admin" = {
              proxyPass = "http://127.0.0.1:${toString config.services.headplane.settings.server.port}/admin";
              basicAuth = secrets.nginx.basicAuth."headplane.00a.ch";

              extraConfig = ''
                satisfy any;

                allow 192.168.2.0/24;
                deny all;
              '';
            };
          };
        };

        "headscale.00a.ch" = {
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
  };

  systemd.services.headscale-setup = {
    after = [ config.systemd.services.headscale.name ];
    wants = [ config.systemd.services.headscale.name ];

    script = ''
      ${pkgs.sqlite-interactive}/bin/sqlite3 ${config.services.headscale.settings.database.sqlite.path} <<EOF
        ${addApiKeySql}

        ${addUserSql}
      EOF
    '';

    serviceConfig = {
      User = config.services.headscale.user;
      Group = config.services.headscale.group;
      Type = "oneshot";
    };
  };

  networking.firewall.allowedUDPPorts = [ 3478 ];
}
