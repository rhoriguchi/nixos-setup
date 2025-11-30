{
  imports = [
    ./_common.nix

    ./alloy.nix
    ./containers.nix
    ./fail2ban.nix
    ./nginx.nix
    ./nix-garbage-collection.nix
  ];
}
