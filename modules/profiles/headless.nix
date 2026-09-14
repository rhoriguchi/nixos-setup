{
  imports = [
    ./_common.nix

    ./alloy
    ./authelia.nix
    ./chrony.nix
    ./containers
    ./fail2ban.nix
    ./grafana.nix
    ./loki.nix
    ./nginx.nix
    ./nix-garbage-collection.nix
  ];
}
