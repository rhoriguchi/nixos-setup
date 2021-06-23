{ config, ... }: {
  imports = [ ../../default.nix ../default.nix ./hardware-configuration.nix ];

  networking.hostName = "XXLPitu-AdGuard";

  # TODO create initial config yaml and than create with nix
  services.adguardhome.enable = true;

  networking.firewall = {
    allowedTCPPorts = [ 53 3000 ];
    allowedUDPPorts = [ 53 ];
  };
}
