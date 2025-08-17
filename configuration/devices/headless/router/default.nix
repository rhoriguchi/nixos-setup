{ lib, secrets, ... }: {
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
    ./web-proxy.nix

    ./hardware-configuration.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = "XXLPitu-Router";

    wireless = {
      enable = true;

      networks.Niflheim = secrets.wifis.Niflheim;
    };
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
