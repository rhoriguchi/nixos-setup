{ config, lib, pkgs, public-keys, ... }: {
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

  time.timeZone = "Europe/Zurich";

  networking.firewall.interfaces.${config.services.wireguard-network.interfaceName}.allowedTCPPorts = config.services.openssh.ports;

  nixpkgs.config.permittedInsecurePackages = [ ]
    # TODO remove when https://github.com/project-chip/connectedhomeip/issues/25688 fixed
    ++ lib.optionals config.services.home-assistant.enable [
      "openssl-1.1.1w"
    ]
    # TODO remove when https://github.com/NixOS/nixpkgs/issues/360592 fixed
    ++ lib.optionals config.services.sonarr.enable [
      "aspnetcore-runtime-6.0.36"
      "aspnetcore-runtime-wrapped-6.0.36"
      "dotnet-sdk-6.0.428"
      "dotnet-sdk-wrapped-6.0.428"
    ];

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
