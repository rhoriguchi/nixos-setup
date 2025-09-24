{ pkgs, ... }:
let
  package = pkgs.nix-output-monitor;
in
{
  home.packages = [ package ];

  programs.zsh.shellAliases = {
    "nix build" = "${package}/bin/nom build";
    "nix shell" = "${package}/bin/nom shell";
    "nix develop" = "${package}/bin/nom develop";

    nix-build = "${package}/bin/nom-build";

    # TODO commented interferes with zsh-nix-shell
    # nix-shell = "${package}/bin/nom-shell";
  };
}
