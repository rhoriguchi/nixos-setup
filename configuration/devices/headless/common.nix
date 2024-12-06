{ pkgs, lib, config, public-keys, secrets, ... }: {
  imports = [ ../../common.nix ];

  nix.gc = {
    automatic = true;
    dates = "05:00";
    options = "--delete-older-than 7d";
  };

  nixpkgs.config.permittedInsecurePackages = [ ]
    # TODO remove when https://github.com/project-chip/connectedhomeip/issues/25688 fixed
    ++ lib.optionals config.services.home-assistant.enable [ "openssl-1.1.1w" ];

  networking = {
    nftables.enable = true;

    networkmanager = {
      ethernet.macAddress = "permanent";
      wifi.macAddress = "permanent";
    };
  };

  environment = {
    systemPackages = [ pkgs.nano ];

    variables.EDITOR = "nano";
  };

  users.users.xxlpitu = {
    extraGroups = [ "wheel" ] ++ (lib.optional config.virtualisation.docker.enable "docker")
      ++ (lib.optional config.virtualisation.podman.enable "podman")
      ++ (lib.optionals config.virtualisation.libvirtd.enable [ "kvm" "libvirtd" ]);
    isNormalUser = true;
    password = secrets.users.xxlpitu.password;
    openssh.authorizedKeys.keys = [ public-keys.default ];
  };

  services = {
    log-shipping = {
      enable = true;

      receiverHostname = "XXLPitu-Server";
    };

    monitoring = {
      enable = true;

      type = "child";
      parentHostname = "XXLPitu-Server";
      apiKey = secrets.monitoring.apiKey;
    };
  };
}
