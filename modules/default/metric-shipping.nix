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

    environment.etc."alloy/prometheus.alloy".text = ''
      prometheus.remote_write "default" {
        endpoint {
          url = "http://${
            if (config.networking.hostName == cfg.receiverHostname) then
              "127.0.0.1"
            else
              tailscaleIps.${cfg.receiverHostname}
          }:9090/api/v1/write"
        }
      }

      prometheus.relabel "default" {
        forward_to = [prometheus.remote_write.default.receiver]

        rule {
          target_label = "hostname"
          replacement = "${config.networking.hostName}"
        }
      }
    '';
  };
}
