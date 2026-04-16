{
  imports = [
    ./_common.nix

    ./alloy.nix
    ./authelia.nix
    ./chrony.nix
    ./fail2ban.nix
    ./grafana.nix
    ./loki.nix
    ./nginx.nix
    ./nix-garbage-collection.nix
  ];
}
