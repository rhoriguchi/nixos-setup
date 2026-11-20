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

          config.bindMounts = lib.genAttrs config.sopsPaths (path: {
            hostPath = path;
            isReadOnly = true;
          });
        }
      )
    );
  };
}
