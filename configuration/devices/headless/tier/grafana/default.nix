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
        forceSSL = true;

        extraConfig = ''
          include /run/nginx-authelia/location.conf;
        '';

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}";

          proxyWebsockets = true;

          extraConfig = ''
            proxy_buffering off;

            include /run/nginx-authelia/auth.conf;

            satisfy any;
            allow 192.168.2.0/24;
            deny all;
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

          enforce_domain = true;
        };

        security.secret_key = secrets.grafana.secretKey;

        auth.disable_login_form = true;

        "auth.anonymous" = {
          enabled = true;

          org_name = "Main Org.";
          org_role = "Editor";
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
