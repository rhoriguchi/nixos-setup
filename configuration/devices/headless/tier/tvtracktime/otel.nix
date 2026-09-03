{ config, lib, ... }:
let
  port = 56710;
in
{
  containers.tvtracktime-application.config.virtualisation.oci-containers.containers.backend.environment.OTEL_EXPORTER_OTLP_TRACES_ENDPOINT =
    "http://${config.containers.tvtracktime-application.hostAddress}:${toString port}/v1/traces";

  environment.etc = lib.mkIf config.services.alloy.enable {
    "alloy/otel.tvtracktime.alloy".text = ''
      otelcol.processor.attributes "tvtracktime" {
        output {
          traces = [otelcol.processor.attributes.default.input]
        }

        action {
          key = "job"
          action = "upsert"
          value = "tvtracktime"
        }
      }

      otelcol.receiver.otlp "tvtracktime" {
        http {
          // modules/profiles/containers.nix DNATs container traffic
          // addressed to hostAddress (169.254.1.1) to 127.0.0.1, so the
          // receiver must bind there, not on hostAddress itself.
          endpoint = "127.0.0.1:${toString port}"
        }

        output {
          traces = [otelcol.processor.attributes.tvtracktime.input]
        }
      }
    '';
  };
}
