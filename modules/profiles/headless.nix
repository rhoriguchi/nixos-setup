{
  imports = [
    ./_common.nix

    ./alloy.nix
    ./containers.nix
    ./fail2ban.nix
    ./loki.nix
    ./nginx.nix
    ./nix-garbage-collection.nix
  ];
}
