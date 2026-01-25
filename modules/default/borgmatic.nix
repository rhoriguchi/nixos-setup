{ config, lib, ... }:
let
  cfg = config.services.borgmatic;

  port = 56701;
in
{
  config = lib.mkIf cfg.enable {
    services.borgmatic.settings = {
      monitoring_verbosity = 2;

      loki = {
        url = "http://127.0.0.1:${toString port}/loki/api/v1/push";

        # Needs at least one label
        labels.job = "borgmatic";

        send_logs = true;
      };
    };

    environment.etc = lib.mkIf config.services.alloy.enable {
      "alloy/loki.borgmatic.alloy".text = ''
        loki.relabel "borgmatic" {
          forward_to = [loki.relabel.default.receiver]

          rule {
            target_label = "job"
            replacement = "borgmatic"
          }
        }

        loki.source.api "borgmatic" {
          http {
            listen_address = "127.0.0.1"
            listen_port = ${toString port}
          }

          forward_to = [loki.relabel.borgmatic.receiver]
        }
      '';
    };
  };
}
