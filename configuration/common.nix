{ config, lib, pkgs, public-keys, ... }: {
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

  time.timeZone = "Europe/Zurich";

  networking = {
    nftables.enable = true;

    firewall.interfaces.${config.services.wireguard-network.interfaceName}.allowedTCPPorts = config.services.openssh.ports;
  };

  nixpkgs.config.permittedInsecurePackages = [ ]
    # TODO remove when https://github.com/project-chip/connectedhomeip/issues/25688 fixed
    ++ lib.optionals config.services.home-assistant.enable [ "openssl-1.1.1w" ];

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
