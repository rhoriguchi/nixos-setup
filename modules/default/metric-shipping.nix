{
  config,
  lib,
  ...
}:
let
  cfg = config.services.metricShipping;

  tailscaleIps = import (
    lib.custom.relativeToRoot "configuration/devices/headless/nelliel/headscale/ips.nix"
  );
in
{
  options.services.metricShipping = {
    enable = lib.mkEnableOption "Ship logs with Grafana Alloy to Loki";
    receiverHostname = lib.mkOption { type = lib.types.nullOr lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.services.tailscale.enable;
        message = "tailscale service must be enabled";
      }
    ];

    services.alloy.enable = true;

    environment.etc = lib.optionalAttrs config.services.netdata.enable {
      "alloy/netdata.alloy".text = ''
        prometheus.remote_write "netdata_endpoint" {
          endpoint {
            url = "http://${
              if (config.networking.hostName == cfg.receiverHostname) then
                "127.0.0.1"
              else
                tailscaleIps.${cfg.receiverHostname}
            }:9090/api/v1/write"
          }
        }

        prometheus.relabel "netdata_add_hostname" {
          forward_to = [prometheus.remote_write.netdata_endpoint.receiver]

          rule {
            action       = "replace"
            target_label = "hostname"
            replacement  = "${config.networking.hostName}"
          }
        }

        prometheus.scrape "netdata" {
          forward_to = [prometheus.relabel.netdata_add_hostname.receiver]

          scrape_interval = "5s"
          scrape_timeout = "5s"

          targets = [
            {
              __address__ = "127.0.0.1:${toString config.services.monitoring.webPort}",
              __metrics_path__ = "/api/v1/allmetrics",
              __param_format = "prometheus",
            },
          ]
        }
      '';
    };
  };
}
