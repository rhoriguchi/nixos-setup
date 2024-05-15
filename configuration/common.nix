{ config, lib, pkgs, public-keys, ... }: {
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

  time.timeZone = "Europe/Zurich";

  networking.firewall.interfaces.${config.services.wireguard-network.interfaceName}.allowedTCPPorts = config.services.openssh.ports;

  services = {
    openssh = {
      enable = true;

      openFirewall = false;

      settings = {
        KbdInteractiveAuthentication = false;
        PasswordAuthentication = false;
      };
    };

    wireguard-network = {
      enable = true;

      type = "client";
      serverHostname = "XXLPitu-Router";
    };
  };

  users = {
    mutableUsers = false;

    users.root = {
      hashedPassword = "*";
      openssh.authorizedKeys.keys = [ public-keys.default ];
    };
  };
}
