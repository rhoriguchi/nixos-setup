{
  config,
  lib,
  ...
}:
let
  cfg = config.services.logShipping;
in
{
  options.services.logShipping = {
    enable = lib.mkEnableOption "Ship metrics with Grafana Alloy to Prometheus";
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

    systemd.services.alloy.serviceConfig.LoadCredential = [ "lokiPushPassword:${cfg.passwordFile}" ];

    environment.etc = {
      "alloy/loki.alloy".text = ''
        loki.write "default" {
          endpoint {
            url = "http://${
              if (config.networking.hostName == cfg.receiverHostname) then
                "127.0.0.1"
              else
                "${cfg.receiverHostname}.tailnet"
            }:3100/loki/api/v1/push"

            basic_auth {
              username = "alloy"
              password_file = sys.env("CREDENTIALS_DIRECTORY") + "/lokiPushPassword"
            }
          }
        }

        loki.process "redact" {
          forward_to = [loki.write.default.receiver]

          stage.replace {
            expression = `(?i)(?:api[_-]?key|auth[_-]?token|access[_-]?token|x-plex-token)=([^&\s"]+)`
            replace = "REDACTED"
          }

          stage.replace {
            expression = `(?i)security password: (\S+)`
            replace = "REDACTED"
          }
        }

        loki.relabel "default" {
          forward_to = [loki.process.redact.receiver]

          rule {
            source_labels = ["hostname"]
            target_label = "hostname"
            regex = "^$"
            replacement = "${config.networking.hostName}"
            action = "replace"
          }
        }
      '';

      "alloy/loki.systemd.alloy".text = ''
        loki.relabel "systemd" {
          forward_to = [loki.relabel.default.receiver]

          rule {
            target_label = "job"
            replacement = "systemd"
          }
        }

        loki.relabel "raw_journal" {
          forward_to = []

          rule {
            source_labels = ["__journal_priority_keyword"]
            target_label = "severity"
          }

          rule {
            source_labels = ["__journal__systemd_unit"]
            target_label = "unit"
            regex = "${
              lib.escape [
                "\\"
              ] ''(.+\.service)''
            }"
          }

          rule {
            source_labels = ["__journal__systemd_unit"]
            regex = "container@(.+)\\.service"
            target_label = "container"
            replacement = "$1"
          }

          rule {
            source_labels = ["__journal__systemd_unit"]
            regex = "container@(.+)\\.service"
            target_label = "job"
            replacement = "container"
          }

          rule {
            source_labels = ["__journal__systemd_user_unit"]
            target_label = "user_unit"
            regex = "${
              lib.escape [
                "\\"
              ] ''(.+\.service)''
            }"
          }
        }

        loki.source.journal "systemd" {
          forward_to = [loki.relabel.systemd.receiver]

          relabel_rules = loki.relabel.raw_journal.rules
        }
      '';
    };
  };
}
