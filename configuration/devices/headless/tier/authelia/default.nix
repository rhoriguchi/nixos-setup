{
  config,
  lib,
  ...
}:
let
  cfg = config.services.authelia.instances.main;

  restartUnit = config.systemd.services."authelia-${cfg.name}".name;

  autheliaUsers = import ./users.nix;

  autheliaUserSecretFields = [
    "displayname"
    "email"
    "password"
  ];

  autheliaUserSecretName = user: field: "services/authelia/users/${user}/${field}";
in
{
  imports = [ ./clients ];

  sops = {
    secrets =
      lib.listToAttrs (
        lib.concatMap (
          user:
          map (field: lib.nameValuePair (autheliaUserSecretName user field) { }) autheliaUserSecretFields
        ) (lib.attrNames autheliaUsers)
      )
      // {
        "services/authelia/oidc/jwks".restartUnits = [ restartUnit ];

        "services/authelia/jwtSecret" = {
          owner = cfg.user;
          group = cfg.group;

          restartUnits = [ restartUnit ];
        };

        "services/authelia/storageEncryptionKey" = {
          owner = cfg.user;
          group = cfg.group;

          restartUnits = [ restartUnit ];
        };

        "services/authelia/sessionSecret" = {
          owner = cfg.user;
          group = cfg.group;

          restartUnits = [ restartUnit ];
        };
      };

    templates."services.authelia.users" = {
      owner = cfg.user;
      group = cfg.group;

      content = lib.toJSON {
        users = lib.mapAttrs (
          user: userCfg:
          {
            inherit (userCfg) groups;
          }
          // lib.listToAttrs (
            map (
              field: lib.nameValuePair field config.sops.placeholder.${autheliaUserSecretName user field}
            ) autheliaUserSecretFields
          )
        ) autheliaUsers;
      };

      restartUnits = [ restartUnit ];
    };
  };

  users.users.${cfg.user}.extraGroups = [ config.services.redis.servers.authelia.group ];

  services = {
    authelia.instances.main = {
      enable = true;

      secrets = {
        jwtSecretFile = config.sops.secrets."services/authelia/jwtSecret".path;
        storageEncryptionKeyFile = config.sops.secrets."services/authelia/storageEncryptionKey".path;
        oidcIssuerPrivateKeyFile = config.sops.secrets."services/authelia/oidc/jwks".path;
        sessionSecretFile = config.sops.secrets."services/authelia/sessionSecret".path;
      };

      settings = {
        theme = "auto";

        server = {
          endpoints.authz.auth-request.implementation = "AuthRequest";

          disable_healthcheck = true;

          buffers.read = 8192;
        };

        session = {
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
            {
              domain_regex = "^(?P<Group>[^.]+)\\.00a\\.ch$";
              policy = "one_factor";
            }
          ];
        };

        authentication_backend = {
          file.path = config.sops.templates."services.authelia.users".path;

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

    custom-netdata.extraPrometheusJobs = [
      {
        name = "Authelia";
        url = "http://127.0.0.1:${lib.last (lib.splitString ":" cfg.settings.telemetry.metrics.address)}/metrics";
      }
    ];

    infomaniak = {
      enable = true;

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
