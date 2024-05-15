{ config, lib, secrets, interfaces, ... }:
let managementInterface = interfaces.management;
in {
  imports = [
    ../common.nix

    ./adguardhome.nix
    ./firewall.nix
    ./routing.nix
    ./web-proxy.nix

    ./hardware-configuration.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = "XXLPitu-Router";

    firewall.interfaces.${managementInterface}.allowedTCPPorts = config.services.openssh.ports;
  };

  services = {
    wireguard-network = lib.mkForce {
      enable = true;
      type = "server";
    };

    infomaniak = {
      enable = true;

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
    };
  };
}
