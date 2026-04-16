{
  config,
  lib,
  pkgs,
  secrets,
  ...
}:
let
  cfg = config.services.authelia.instances.main;
in
{
  imports = [
    ./grafana.nix
    ./home-assistant.nix
    ./jellyfin.nix
  ];

  users.users.${cfg.user}.extraGroups = [ config.services.redis.servers.authelia.group ];

  services = {
    authelia.instances.main = {
      enable = true;

      secrets = {
        jwtSecretFile = pkgs.writeText "authelia-jwt-secret" secrets.authelia.jwtSecret;
        storageEncryptionKeyFile = pkgs.writeText "authelia-storage-encryption-key" secrets.authelia.storageEncryptionKey;
      };

      settings = {
        theme = "auto";

        server = {
          endpoints.authz.auth-request.implementation = "AuthRequest";

          disable_healthcheck = true;

          buffers.read = 8192;
        };

        session = {
          secret = secrets.authelia.sessionSecret;

          cookies = [
            {
              authelia_url = "https://authelia.00a.ch";
              domain = "00a.ch";
            }
          ];

          redis.host = config.services.redis.servers.authelia.unixSocket;
        };

        access_control = {
          default_policy = "deny";
          rules = [
            {
              domain = "*.00a.ch";
              subject = [ "group:admin" ];
              policy = "one_factor";
            }
          ];
        };

        identity_providers.oidc.jwks = [
          {
            key = lib.readFile ./rsa.2048.key;
          }
        ];

        authentication_backend = {
          file.path = (pkgs.formats.yaml { }).generate "authelia-users.yaml" {
            users = lib.mapAttrs (
              key: value:
              {
                displayname = lib.toLower key;
              }
              // value
            ) secrets.authelia.users;
          };

          password_reset.disable = true;
          password_change.disable = true;
        };

        storage.postgres = {
          address = "unix:///run/postgresql";
          database = cfg.user;
          username = cfg.user;
        };

        notifier.filesystem.filename = "/var/lib/authelia-${cfg.name}/notifications.txt";

        log.level = "info";

        telemetry.metrics.enabled = true;
      };
    };

    postgresql = {
      enable = true;

      ensureDatabases = [ cfg.user ];
      ensureUsers = [
        {
          name = cfg.user;
          ensureDBOwnership = true;
        }
      ];
    };

    redis.servers.authelia = {
      enable = true;

      port = 0;
    };

    monitoring.extraPrometheusJobs = [
      {
        name = "Authelia";
        url = "http://127.0.0.1:${lib.last (lib.splitString ":" cfg.settings.telemetry.metrics.address)}/metrics";
      }
    ];

    infomaniak = {
      enable = true;

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
      hostnames = [ "authelia.00a.ch" ];
    };

    nginx = {
      enable = true;

      virtualHosts."authelia.00a.ch" = {
        enableACME = true;
        acmeRoot = null;
        forceSSL = true;

        locations."/".proxyPass =
          "http://127.0.0.1:${lib.last (lib.splitString ":" cfg.settings.server.address)}";
      };
    };
  };
}
