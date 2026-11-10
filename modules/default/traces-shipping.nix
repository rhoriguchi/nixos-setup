{
  config,
  lib,
  ...
}:
let
  cfg = config.services.tracesShipping;
in
{
  options.services.tracesShipping = {
    enable = lib.mkEnableOption "Ship traces with Grafana Alloy to Tempo";
    receiverHostname = lib.mkOption { type = lib.types.nullOr lib.types.nonEmptyStr; };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.services.tailscale.enable;
        message = "tailscale service must be enabled";
      }
    ];

    services.alloy.enable = true;

    environment.etc."alloy/tempo.alloy".text = ''
      otelcol.exporter.otlp "default" {
        client {
          endpoint = "${
            if (config.networking.hostName == cfg.receiverHostname) then
              "127.0.0.1"
            else
              "${cfg.receiverHostname}.tailnet"
          }:4317"

          tls {
            insecure = true
          }
        }
      }

      otelcol.processor.attributes "default" {
        output {
          traces = [otelcol.exporter.otlp.default.input]
        }

        action {
          key = "hostname"
          action = "upsert"
          value = "${config.networking.hostName}"
        }
      }
    '';
  };
}
