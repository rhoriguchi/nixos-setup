{
  config,
  lib,
  libCustom,
  ...
}:
let
  cfg = config.services.metricShipping;

  tailscaleIps = import (
    libCustom.relativeToRoot "configuration/devices/headless/nelliel/headscale/ips.nix"
  );
in
{
  options.services.metricShipping = {
    enable = lib.mkEnableOption "Ship logs with Grafana Alloy to Loki";
    receiverHostname = lib.mkOption { type = lib.types.nullOr lib.types.nonEmptyStr; };
    passwordFile = lib.mkOption { type = lib.types.path; };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.services.tailscale.enable;
        message = "tailscale service must be enabled";
      }
    ];

    services.alloy.enable = true;

    systemd.services.alloy.serviceConfig.LoadCredential = [
      "prometheusPushPassword:${cfg.passwordFile}"
    ];

    environment.etc."alloy/prometheus.alloy".text = ''
      prometheus.remote_write "default" {
        endpoint {
          url = "http://${
            if (config.networking.hostName == cfg.receiverHostname) then
              "127.0.0.1"
            else
              tailscaleIps.${cfg.receiverHostname}.ip
          }:9090/api/v1/write"

          basic_auth {
            username = "alloy"
            password_file = sys.env("CREDENTIALS_DIRECTORY") + "/prometheusPushPassword"
          }
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
