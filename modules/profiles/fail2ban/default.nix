{
  config,
  lib,
  pkgs,
  ...
}:
let
  format = pkgs.formats.ini { };
in
{
  imports = [
    ./authelia.nix
    ./home-assistant.nix
    ./immich.nix
    ./nginx.nix
    ./webdav.nix
  ];

  services.fail2ban = {
    ignoreIP = [
      "10.0.0.0/8"
      "172.16.0.0/12"
      "192.168.0.0/16"
    ]
    ++ lib.pipe config.containers [
      (lib.mapAttrsToList (_: container: container.localAddress))
      (lib.filter (address: address != null))
    ];

    bantime = "1h";

    bantime-increment = {
      enable = true;

      maxtime = "7d";
    };

    maxretry = 3;
  };

  environment.etc."fail2ban/action.d/nftables-common.local".source =
    format.generate "nftables-common.local"
      {
        Definition.rule_stat = "<addr_family> saddr @<addr_set> <blocktype>";

        Init.blocktype = "drop";
      };
}
