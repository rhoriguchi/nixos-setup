{
  imports = [
    ./_common.nix

    ./alloy.nix
    ./containers.nix
    ./fail2ban.nix
    ./grafana.nix
    ./loki.nix
    ./nginx.nix
    ./nix-garbage-collection.nix
  ];
}
