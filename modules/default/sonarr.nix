{ config, lib, ... }:
let
  cfg = config.services.sonarr;
in
{
  config = lib.mkIf cfg.enable {
    systemd.services.alloy.serviceConfig = {
      SupplementaryGroups = [ cfg.user ];
      BindReadOnlyPaths = [
        "${cfg.dataDir}/logs"
      ];
    };

    environment.etc = lib.mkIf config.services.alloy.enable {
      "alloy/loki.sonarr.alloy".text = ''
        loki.relabel "sonarr" {
          forward_to = [loki.relabel.default.receiver]

          rule {
            target_label = "job"
            replacement = "sonarr"
          }

          rule {
            action = "labeldrop"
            regex = "filename"
          }
        }

        loki.process "sonarr" {
          forward_to = [loki.relabel.sonarr.receiver]

          stage.regex {
            expression = "${
              lib.escape [
                "\\"
              ] ''^(?P<timestamp>\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d)\|(?P<severity>[[:alpha:]]+)|''
            }"
          }

          stage.template {
            source = "severity"
            template = "{{ ToLower .severity }}"
          }

          stage.labels {
            values = {
              severity = "",
            }
          }

          stage.drop {
            source = "severity"
            value = "debug"
          }
        }

        loki.source.file "sonarr" {
          targets = [
            {__path__ = "${cfg.dataDir}/logs/sonarr.debug.txt"},
          ]

          forward_to = [loki.process.sonarr.receiver]
        }
      '';
    };
  };
}
