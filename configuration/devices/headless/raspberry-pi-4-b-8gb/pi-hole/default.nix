{ pkgs, ... }: {
  imports = [ ../../default.nix ../default.nix ./hardware-configuration.nix ];

  networking.hostName = "XXLPitu-Pi-Hole";

  services.pi-hole = {
    enable = true;

    serverIp = "192.168.1.3";
    password = (import ../../../../secrets.nix).services.duckdns.token;
  };
}
