{
  imports = [
    ./_common.nix
    ./headless-common.nix

    ./alloy
    ./authelia.nix
    ./chrony.nix
    ./containers
    ./fail2ban.nix
    ./grafana.nix
    ./infomaniak.nix
    ./loki.nix
    ./netdata.nix
    ./nginx.nix
    ./nix-garbage-collection.nix
  ];
}
