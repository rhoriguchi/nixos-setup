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
    ./sops.nix
  ];

  options.containers = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { name, ... }:
        {
          config.config = {
            networking.hostName = "${config.networking.hostName}-${name}";

            nixpkgs.pkgs = pkgs;

            system.stateVersion = config.system.stateVersion;
          };
        }
      )
    );
  };
}
