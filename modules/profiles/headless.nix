{
  imports = [
    ./_common.nix

    ./alloy.nix
    ./authelia.nix
    ./fail2ban.nix
    ./grafana.nix
    ./loki.nix
    ./nginx.nix
    ./nix-garbage-collection.nix
  ];
}
