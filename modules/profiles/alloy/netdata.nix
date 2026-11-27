{ config, lib, ... }:
let
  cfg = config.services.custom-netdata;
in
{
  config = lib.mkIf (cfg.enable && config.services.alloy.enable) {
    environment.etc = lib.mkMerge [
      {
        "alloy/prometheus.netdata.alloy".text = ''
          prometheus.scrape "netdata" {
            forward_to = [prometheus.relabel.default.receiver]

            scrape_interval = "5s"
            scrape_timeout = "5s"

            targets = [
              {
                __address__ = "127.0.0.1:${toString cfg.webPort}",
                __metrics_path__ = "/api/v1/allmetrics",
                __param_format = "prometheus",
              },
            ]
          }
        '';
      }

      # A parent's /api/v1/allmetrics only exports its own charts, streamed
      # child nodes are only reachable through /host/<hostname>/.
      (lib.pipe config.containers [
        (lib.filterAttrs (
          _: container: cfg.parent.enable && container.config.services.custom-netdata.child.enable
        ))

        (lib.mapAttrs' (
          containerName: container:
          let
            safeContainerName = lib.replaceStrings [ "-" ] [ "_" ] containerName;
          in
          {
            name = "alloy/prometheus.container.${containerName}.alloy";
            value.text = ''
              prometheus.relabel "container_${safeContainerName}" {
                forward_to = [prometheus.relabel.default.receiver]

                rule {
                  target_label = "container"
                  replacement = "${containerName}"
                }
              }

              prometheus.scrape "container_${safeContainerName}" {
                forward_to = [prometheus.relabel.container_${safeContainerName}.receiver]

                scrape_interval = "5s"
                scrape_timeout = "5s"

                targets = [
                  {
                    __address__ = "127.0.0.1:${toString cfg.webPort}",
                    __metrics_path__ = "/host/${container.config.networking.hostName}/api/v1/allmetrics",
                    __param_format = "prometheus",
                  },
                ]
              }
            '';
          }
        ))
      ])
    ];
  };
}
