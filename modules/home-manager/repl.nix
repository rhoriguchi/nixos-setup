{
  config,
  osConfig,
  pkgs,
  ...
}:
{
  programs.zsh.shellAliases = {
    "repl-flake" = ''${
      if pkgs.stdenv.isDarwin then pkgs.nixos-rebuild-ng else osConfig.system.build.nixos-rebuild
    }/bin/nixos-rebuild repl --flake "${config.home.homeDirectory}/Sync/Git/nixos-setup"'';
    "repl-pkgs" = ''${config.nix.package}/bin/nix repl --expr "import <nixpkgs> {}"'';
  };
}
