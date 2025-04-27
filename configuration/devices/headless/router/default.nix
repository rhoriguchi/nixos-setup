{ config, interfaces, lib, secrets, ... }:
let managementInterface = interfaces.management;
in {
  imports = [
    ../common.nix

    ./broken-emmc.nix
    ./dhcp
    ./dns
    ./firewall.nix
    ./interfaces.nix
    ./lancache.nix
    ./networking.nix
    ./unifi.nix
    ./web-proxy

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
