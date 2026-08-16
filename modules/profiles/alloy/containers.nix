{ config, lib, ... }:
let
  containerNames = lib.attrNames config.containers;
in
{
  options.containers = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { name, ... }:
        {
          config = lib.mkIf config.services.alloy.enable {
            bindMounts."/var/log/journal" = {
              hostPath = "/mnt/nixos-containers/${name}";
              isReadOnly = false;
            };
          };
        }
      )
    );
  };

  config = lib.mkIf (config.services.alloy.enable && (config.containers != { })) {
    systemd.tmpfiles.rules = [
      "d /mnt/nixos-containers 0755 root root -"
    ]
    ++ map (containerName: "d /mnt/nixos-containers/${containerName} 0755 root root -") containerNames;

    systemd.services.alloy.serviceConfig = {
      BindReadOnlyPaths = [ "/mnt/nixos-containers" ];
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

                path = "/mnt/nixos-containers/${containerName}"

                relabel_rules = loki.relabel.raw_journal.rules
              }
            '';
          };
        }
      ) containerNames
    );
  };
}
