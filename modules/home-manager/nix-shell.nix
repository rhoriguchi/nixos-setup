{ config, ... }:
let
  package = config.programs.nix-your-shell.nix-output-monitor.package;
in
{
  programs = {
    nix-your-shell = {
      enable = true;

      enableFishIntegration = true;
      enableNushellIntegration = true;
      enableZshIntegration = true;

      nix-output-monitor.enable = true;
    };

    zsh.shellAliases = {
      "nix build" = "${package}/bin/nom build";
      "nix develop" = "${package}/bin/nom develop";
      nix-build = "${package}/bin/nom-build";

      # TODO commented interferes with nix-your-shell
      # "nix shell" = "${package}/bin/nom shell";
      # nix-shell = "${package}/bin/nom-shell";
    };
  };
}
