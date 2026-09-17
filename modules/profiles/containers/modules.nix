{
  lib,
  hostModules,
  libCustom,
  ...
}:
{
  options.containers = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        config = {
          config.imports = [ hostModules ];

          specialArgs = {
            inherit libCustom;
          };
        };
      }
    );
  };
}
