{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./modules.nix
    ./networking.nix
  ];

  options.containers = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        config.config = {
          nixpkgs.pkgs = pkgs;

          system.stateVersion = config.system.stateVersion;
        };
      }
    );
  };
}
