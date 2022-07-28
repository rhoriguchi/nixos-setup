{ pkgs, lib, config, public-keys, secrets, ... }: {
  imports = [
    ../common.nix

    ./audio-converter
    ./rsnapshot.nix
    ./synology-mounts.nix

    ./hardware-configuration.nix
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  networking = {
    hostName = "JDH-Server";

    interfaces = {
      enp8s0.useDHCP = true; # Ethernet
      wlp6s0.useDHCP = true; # WiFi
    };
  };

  services = {
    plex = {
      enable = true;

      openFirewall = true;
    };

    tautulli = {
      enable = true;

      openFirewall = true;
    };

    wireguard-vpn = {
      enable = true;

      type = "client";
    };
  };

  users.users.jdh = {
    extraGroups = [ "wheel" ];
    isNormalUser = true;
    password = secrets.users.users.jdh.password;
    openssh.authorizedKeys.keys = [ public-keys.jdh ];
  };
}
