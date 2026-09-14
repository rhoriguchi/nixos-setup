{ lib, ... }:
{
  options.containers = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { config, ... }:
        {
          options.sopsPaths = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
          };

          config.bindMounts = lib.listToAttrs (
            map (
              path:
              lib.nameValuePair path {
                hostPath = path;
                isReadOnly = true;
              }
            ) config.sopsPaths
          );
        }
      )
    );
  };
}
