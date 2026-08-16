{ config, lib, ... }:
let
  containerNames = lib.attrNames config.containers;
in
{
  config = lib.mkIf (config.services.alloy.enable && (config.containers != { })) {
    systemd.services.alloy.serviceConfig = {
      CapabilityBoundingSet = [ "CAP_DAC_READ_SEARCH" ];
      AmbientCapabilities = [ "CAP_DAC_READ_SEARCH" ];

      BindReadOnlyPaths = [ "/run/nixos-containers" ];
    };

    environment.etc = lib.listToAttrs (
      map (
        containerName:
        let
          safeContainerName = lib.replaceStrings [ "-" ] [ "_" ] containerName;
        in
        {
          name = "alloy/loki.container.${containerName}.alloy";
          value = {
            text = ''
              loki.relabel "container_${safeContainerName}" {
                forward_to = [loki.relabel.default.receiver]

                rule {
                  target_label = "job"
                  replacement = "container"
                }

                rule {
                  target_label = "container"
                  replacement = "${containerName}"
                }
              }

              loki.source.journal "container_${safeContainerName}" {
                forward_to = [loki.relabel.container_${safeContainerName}.receiver]

                path = string.join([
                  string.split(coalesce(local.file_match.container_${safeContainerName}.targets, [{ "__path__" = "/run/nixos-containers/${containerName}/var/log/journal/dummy/system.journal" }])[0].__path__, "/")[0],
                  string.split(coalesce(local.file_match.container_${safeContainerName}.targets, [{ "__path__" = "/run/nixos-containers/${containerName}/var/log/journal/dummy/system.journal" }])[0].__path__, "/")[1],
                  string.split(coalesce(local.file_match.container_${safeContainerName}.targets, [{ "__path__" = "/run/nixos-containers/${containerName}/var/log/journal/dummy/system.journal" }])[0].__path__, "/")[2],
                  string.split(coalesce(local.file_match.container_${safeContainerName}.targets, [{ "__path__" = "/run/nixos-containers/${containerName}/var/log/journal/dummy/system.journal" }])[0].__path__, "/")[3],
                  string.split(coalesce(local.file_match.container_${safeContainerName}.targets, [{ "__path__" = "/run/nixos-containers/${containerName}/var/log/journal/dummy/system.journal" }])[0].__path__, "/")[4],
                  string.split(coalesce(local.file_match.container_${safeContainerName}.targets, [{ "__path__" = "/run/nixos-containers/${containerName}/var/log/journal/dummy/system.journal" }])[0].__path__, "/")[5],
                  string.split(coalesce(local.file_match.container_${safeContainerName}.targets, [{ "__path__" = "/run/nixos-containers/${containerName}/var/log/journal/dummy/system.journal" }])[0].__path__, "/")[6],
                ], "/")

                relabel_rules = loki.relabel.raw_journal.rules
              }

              local.file_match "container_${safeContainerName}" {
                path_targets = [{
                  "__path__" = "/run/nixos-containers/.#snapshot.${containerName}*/var/log/journal/**/system.journal",
                }]
              }
            '';
          };
        }
      ) containerNames
    );
  };
}
