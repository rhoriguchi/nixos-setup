{
  config,
  secrets,
  ...
}:
{
  services = {
    nginx = {
      enable = true;

      virtualHosts."grafana.00a.ch" = {
        enableACME = true;
        acmeRoot = null;
        forceSSL = true;

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}";

          proxyWebsockets = true;

          extraConfig = ''
            proxy_buffering off;
          '';
        };
      };
    };

    infomaniak = {
      enable = true;

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
      hostnames = [
        "grafana.00a.ch"
      ];
    };

    grafana = {
      enable = true;

      settings = {
        server = {
          domain = "grafana.00a.ch";
          root_url = "https://grafana.00a.ch";
          enforce_domain = true;
        };

        security.secret_key = secrets.grafana.secretKey;

        auth.disable_login_form = true;

        "auth.generic_oauth" = {
          enabled = true;

          name = "Authelia";
          allow_sign_up = true;
          client_id = "grafana";
          client_secret = secrets.authelia.oidcClientSecrets.grafana.secret;

          scopes = "openid profile groups email";
          auth_url = "https://authelia.00a.ch/api/oidc/authorization";
          token_url = "https://authelia.00a.ch/api/oidc/token";
          api_url = "https://authelia.00a.ch/api/oidc/userinfo";

          role_attribute_path = "contains(groups, 'admin') && 'Admin' || contains(groups, 'grafana') && 'Viewer'";
        };
      };

      provision = {
        enable = true;

        dashboards.settings = {
          apiVersion = 1;

          providers = [
            {
              name = "Dashboards";
              updateIntervalSeconds = 60 * 60;
              options.path = ./dashboards;
            }
          ];
        };

        datasources.settings = {
          apiVersion = 1;

          datasources = [
            {
              name = "Loki";
              type = "loki";
              access = "proxy";
              url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}";
              isDefault = true;
            }
            {
              name = "Prometheus";
              type = "prometheus";
              access = "proxy";
              url = "http://127.0.0.1:${toString config.services.prometheus.port}";

              jsonData = {
                manageAlerts = true;
                prometheusType = "Prometheus";
                prometheusVersion = config.services.prometheus.package.version;
                cacheLevel = "High";
              };
            }
          ];
        };
      };
    };
  };
}
