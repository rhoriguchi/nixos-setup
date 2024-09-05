{ config, secrets, ... }: {
  services = {
    nginx = {
      enable = true;

      virtualHosts."grafana.00a.ch" = {
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}";
          proxyWebsockets = true;
        };
      };
    };

    infomaniak = {
      enable = true;

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
      hostnames = [ "grafana.00a.ch" ];
    };

    grafana = {
      enable = true;

      settings = {
        server.domain = "grafana.00a.ch";

        security = {
          secret_key = secrets.grafana.secret_key;

          admin_user = "admin";
          admin_password = secrets.grafana.users.${config.services.grafana.settings.security.admin_user}.password;
        };

        users.login_hint = "password";
      };
    };
  };
}
