{
  config,
  osConfig,
  ...
}:
let
  homeDirectory = config.home.homeDirectory;
in
{
  programs.zsh.shellAliases = {
    "repl-flake" =
      ''${osConfig.system.build.nixos-rebuild}/bin/nixos-rebuild repl --flake "${homeDirectory}/Sync/Git/nixos-setup"'';
    "repl-pkgs" = ''${config.nix.package}/bin/nix repl --expr "import <nixpkgs> {}"'';
  };
}
