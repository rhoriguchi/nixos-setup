{ config, lib, ... }:
let
  cfg = config.services.custom-netdata;

  containerNames = lib.attrNames config.containers;
in
{
  options.containers = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { config, name, ... }:
        {
          config = {
            bindMounts."/var/lib/netdata" = lib.mkIf cfg.enable {
              hostPath = "/mnt/nixos-containers/${name}/netdata";
              isReadOnly = false;
            };

            config.services.custom-netdata = {
              enable = cfg.enable;

              ephemeral = config.ephemeral;

              child = {
                enable = cfg.enable;
                parentAddress = config.hostAddress;
              };

              streamConf.apiKey = cfg.localApiKey;
            };
          };
        }
      )
    );
  };

  config = lib.mkIf (cfg.enable && (config.containers != { })) {
    systemd.tmpfiles.rules = [
      "d /mnt/nixos-containers 0755 root root -"
    ]
    ++ map (
      containerName: "d /mnt/nixos-containers/${containerName}/netdata 0755 root root -"
    ) containerNames;
  };
}
