{
  config,
  lib,
  pkgs,
  secrets,
  ...
}:
let
  cfg = config.services.authelia.instances.main;

  localDomains = [
    "adguardhome.00a.ch"
    "deluge.00a.ch"
    "grafana.00a.ch"
    "monitoring.00a.ch"
    "prometheus.00a.ch"
    "prowlarr.00a.ch"
    "sonarr.00a.ch"
    "tautulli.00a.ch"
  ];
in
{
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

        session.cookies = [
          {
            authelia_url = "https://authelia.00a.ch";
            domain = "00a.ch";
          }
        ];

        access_control = {
          default_policy = "one_factor";

          rules = [
            {
              domain = localDomains;
              policy = "bypass";
              networks = [ "192.168.2.0/24" ];
            }
          ];
        };

        authentication_backend = {
          file.path = (pkgs.formats.yaml { }).generate "authelia-users" {
            users = lib.mapAttrs (
              key: value:
              {
                displayname = lib.toSentenceCase key;
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
        forceSSL = true;

        locations."/".proxyPass =
          "http://127.0.0.1:${lib.last (lib.splitString ":" cfg.settings.server.address)}";
      };
    };
  };
}
