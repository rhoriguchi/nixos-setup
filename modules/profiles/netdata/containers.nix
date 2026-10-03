{ config, lib, ... }:
let
  cfg = config.services.custom-netdata;
in
{
  options.containers = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { config, ... }:
        {
          config.config.services.custom-netdata = {
            enable = cfg.enable;

            ephemeral = config.ephemeral;

            child = {
              enable = cfg.enable;
              parentAddress = config.hostAddress;
            };

            streamConf.apiKey = cfg.localApiKey;
          };
        }
      )
    );
  };
}
