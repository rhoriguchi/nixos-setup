{
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  environment.shellAliases.sflake = "nix flake";
}
