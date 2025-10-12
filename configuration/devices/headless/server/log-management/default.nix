{
  config,
  lib,
  secrets,
  ...
}:
{
  fileSystems = {
    "/mnt/Data/Monitoring/loki" = {
      depends = [ "/mnt/Data/Monitoring" ];
      device = config.services.loki.dataDir;
      fsType = "none";
      options = [ "bind" ];
    };

    "/mnt/Data/Monitoring/prometheus" = {
      depends = [ "/mnt/Data/Monitoring" ];
      device = "/var/lib/${config.services.prometheus.stateDir}";
      fsType = "none";
      options = [ "bind" ];
    };
  };

  services = {
    nginx = {
      enable = true;

      virtualHosts = {
        "grafana.00a.ch" = {
          enableACME = true;
          forceSSL = true;

          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}";
            proxyWebsockets = true;
            basicAuth = secrets.nginx.basicAuth."grafana.00a.ch";

            extraConfig = ''
              proxy_buffering off;

              satisfy any;

              allow 192.168.2.0/24;
              deny all;
            '';
          };
        };

        "prometheus.00a.ch" = {
          enableACME = true;
          forceSSL = true;

          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString config.services.prometheus.port}";
            basicAuth = secrets.nginx.basicAuth."prometheus.00a.ch";

            extraConfig = ''
              satisfy any;

              allow 192.168.2.0/24;
              deny all;
            '';
          };
        };
      };
    };

    infomaniak = {
      enable = true;

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
      hostnames = [
        "grafana.00a.ch"
        "prometheus.00a.ch"
      ];
    };

    grafana = {
      enable = true;

      settings = {
        server = rec {
          domain = "grafana.00a.ch";
          root_url = "https://${domain}";
        };

        security.secret_key = secrets.grafana.secret_key;

        auth.disable_login_form = true;

        "auth.anonymous" = {
          enabled = true;

          org_name = "Main Org.";
          org_role = "Editor";
        };

        analytics = {
          enabled = false;
          check_for_updates = false;
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
              access = "direct";
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

    loki = {
      enable = true;

      extraFlags = [ "-print-config-stderr" ];

      configuration = {
        auth_enabled = false;

        server = {
          http_listen_address = "0.0.0.0";
          http_listen_port = 3100;

          grpc_listen_port = 0;
        };

        ingester.lifecycler = {
          address = "127.0.0.1";

          ring = {
            kvstore.store = "inmemory";

            replication_factor = 1;
          };
        };

        # https://grafana.com/docs/loki/latest/operations/storage/schema
        schema_config = {
          configs = [
            {
              from = "2024-01-01";
              object_store = "filesystem";
              store = "tsdb";
              schema = "v13";
              index = {
                prefix = "index_";
                period = "24h";
              };
            }
          ];
        };

        storage_config = {
          tsdb_shipper = {
            active_index_directory = "${config.services.loki.dataDir}/tsdb-index";
            cache_location = "${config.services.loki.dataDir}/tsdb-cache";
          };

          filesystem.directory = "${config.services.loki.dataDir}/chunks";
        };

        compactor = {
          working_directory = config.services.loki.dataDir;

          compactor_ring.kvstore.store = "inmemory";
        };

        analytics.reporting_enabled = false;
        tracing.enabled = false;
      };
    };

    prometheus = {
      enable = true;

      scrapeConfigs = [
        {
          job_name = "netdata";
          scheme = "https";
          metrics_path = "/api/v1/allmetrics";
          params.format = [ "prometheus_all_hosts" ];
          basic_auth =
            let
              basicAuth = secrets.nginx.basicAuth."monitoring.00a.ch";
            in
            {
              username = lib.head (lib.attrNames basicAuth);
              password = lib.head (lib.attrValues basicAuth);
            };
          static_configs = [ { targets = [ "monitoring.00a.ch" ]; } ];
          scrape_interval = "5s";
        }
      ];
    };

    log-shipping.useLocalhost = true;
  };

  networking.firewall.interfaces.${config.services.tailscale.interfaceName}.allowedTCPPorts = [
    config.services.loki.configuration.server.http_listen_port
  ];
}
