{ config, osConfig, ... }:
{
  programs.zsh.shellAliases = {
    "repl-flake" =
      ''${osConfig.system.build.nixos-rebuild}/bin/nixos-rebuild repl --flake "${config.home.homeDirectory}/Sync/Git/nixos-setup"'';
    "repl-pkgs" =
      ''${config.nix.package}/bin/nix repl --expr "import (builtins.getFlake \"${config.home.homeDirectory}/Sync/Git/nixos-setup\").inputs.nixpkgs {}"'';
  };
}
