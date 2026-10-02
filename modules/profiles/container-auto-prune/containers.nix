{ lib, ... }:
{
  options.containers = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        config.config.imports = [ ./host.nix ];
      }
    );
  };
}
