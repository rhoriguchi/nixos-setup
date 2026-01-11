{
  config,
  lib,
  ...
}:
let
  cfg = config.services.logShipping;

  tailscaleIps = import (
    lib.custom.relativeToRoot "configuration/devices/headless/nelliel/headscale/ips.nix"
  );
in
{
  options.services.logShipping = {
    enable = lib.mkEnableOption "Ship metrics with Grafana Alloy to Prometheus";
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

    environment.etc."alloy/journal.alloy".text = ''
      loki.write "journal_endpoint" {
        endpoint {
          url = "http://${
            if (config.networking.hostName == cfg.receiverHostname) then
              "127.0.0.1"
            else
              tailscaleIps.${cfg.receiverHostname}
          }:3100/loki/api/v1/push"
        }
      }

      loki.relabel "journal" {
        forward_to = []

        rule {
          source_labels = ["__journal__hostname"]
          target_label = "hostname"
        }

        rule {
          source_labels = ["__journal_priority_keyword"]
          target_label = "severity"
        }

        rule {
          source_labels = ["__journal__systemd_unit"]
          target_label = "unit"
          regex = "(.+\\.service)"
        }

        rule {
          source_labels = ["__journal__systemd_user_unit"]
          target_label = "user_unit"
          regex = "(.+\\.service)"
        }
      }

      loki.source.journal "journal" {
        forward_to    = [loki.write.journal_endpoint.receiver]
        relabel_rules = loki.relabel.journal.rules

        labels = {
          job = "systemd",
        }
      }
    '';
  };
}
