{
  config,
  lib,
  pkgs,
  secrets,
  ...
}:
let
  aiProviders = [
    {
      name = "Ollama - qwen2.5vl:7b";
      baseUrl = "http://${config.services.ollama.host}:${toString config.services.ollama.port}/v1";
      apiKey = "ollama";
      model = "qwen2.5vl:7b";
      image = true;
    }
  ];

  mealieSetupScript =
    pkgs.writers.writePython3 "mealie-setup"
      {
        libraries = [ pkgs.python3Packages.requests ];
        flakeIgnore = [ "E501" ];
      }
      (
        lib.readFile (
          pkgs.replaceVars ./script.py {
            baseUrl = "http://127.0.0.1:${toString config.services.mealie.port}";

            defaultUsername = "admin";
            defaultPassword = "MyPassword";
            newPassword = secrets.mealie.bootstrapAdminPassword;

            setupUserName = "Setup User";
            setupUserEmail = config.security.acme.defaults.email;

            aiProviders = builtins.toJSON aiProviders;
          }
        )
      );
in
{
  services = {
    mealie = {
      enable = true;

      database.createLocally = true;

      settings = {
        BASE_URL = "https://mealie.00a.ch";

        # https://docs.mealie.io/documentation/getting-started/authentication/oidc-v2
        OIDC_AUTH_ENABLED = "true";
        OIDC_SIGNUP_ENABLED = "true";
        OIDC_CONFIGURATION_URL = "https://authelia.00a.ch/.well-known/openid-configuration";
        OIDC_CLIENT_ID = "mealie";
        OIDC_CLIENT_SECRET = secrets.authelia.oidcClientSecrets.mealie.secret;
        OIDC_AUTO_REDIRECT = "false";
        OIDC_ADMIN_GROUP = "admin";
        OIDC_USER_GROUP = "mealie";
      };
    };

    infomaniak = {
      enable = true;

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
      hostnames = [ "mealie.00a.ch" ];
    };

    nginx = {
      enable = true;

      virtualHosts."mealie.00a.ch" = {
        enableACME = true;
        acmeRoot = null;
        forceSSL = true;

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.mealie.port}";

          proxyWebsockets = true;

          extraConfig = ''
            proxy_buffering off;
          '';
        };
      };
    };
  };

  systemd.services.mealie-setup = {
    wants = [ config.systemd.services.mealie.name ];
    after = [ config.systemd.services.mealie.name ];
    wantedBy = [ "multi-user.target" ];

    script = "${mealieSetupScript}";

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };
}
