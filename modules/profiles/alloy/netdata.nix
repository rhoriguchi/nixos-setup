{ config, lib, ... }:
let
  cfg = config.services.netdata;

  port = 19999;
in
{
  config = lib.mkIf cfg.enable {
    environment.etc = lib.mkIf config.services.alloy.enable {
      "alloy/prometheus.netdata.alloy".text = ''
        prometheus.scrape "netdata" {
          forward_to = [prometheus.relabel.default.receiver]

          scrape_interval = "5s"
          scrape_timeout = "5s"

          targets = [
            {
              __address__ = "127.0.0.1:${toString port}",
              __metrics_path__ = "/api/v1/allmetrics",
              __param_format = "prometheus",
            },
          ]
        }
      '';
    };
  };
}
