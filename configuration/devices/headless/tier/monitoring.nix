{
  config,
  lib,
  secrets,
  ...
}:
{
  services = {
    nginx = {
      enable = true;

      virtualHosts."monitoring.00a.ch" = {
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.monitoring.webPort}";
          basicAuth = secrets.nginx.basicAuth."monitoring.00a.ch";

          extraConfig = ''
            satisfy any;

            allow 192.168.2.0/24;
            deny all;
          '';
        };
      };
    };

    alloy.enable = true;

    infomaniak = {
      enable = true;

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
      hostnames = [ "monitoring.00a.ch" ];
    };

    monitoring = lib.mkForce {
      enable = true;

      type = "parent";
      claimToken = secrets.monitoring.claimToken;
      apiKey = secrets.monitoring.apiKey;
      discordWebhookUrl = secrets.monitoring.discordWebhookUrl;
    };
  };

  environment.etc."alloy/netdata.alloy".text = ''
    prometheus.remote_write "netdata_endpoint" {
      endpoint {
        url = "http://127.0.0.1:${toString config.services.prometheus.port}/api/v1/write"
      }
    }

    prometheus.scrape "netdata" {
      forward_to = [prometheus.remote_write.netdata_endpoint.receiver]

      scrape_interval = "5s"
      scrape_timeout = "5s"

      targets = [
        {
          __address__ = "127.0.0.1:${toString config.services.monitoring.webPort}",
          __metrics_path__ = "/api/v1/allmetrics",
          __param_format = "prometheus_all_hosts",
        },
      ]
    }
  '';
}
