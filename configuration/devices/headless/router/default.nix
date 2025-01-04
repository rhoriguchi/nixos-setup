{ config, interfaces, lib, secrets, ... }:
let managementInterface = interfaces.management;
in {
  imports = [
    ../common.nix

    ./adguardhome.nix
    ./broken-emmc.nix
    ./firewall.nix
    ./lancache.nix
    ./librenms.nix
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

    snmpd = {
      enable = true;

      listenAddress = "127.0.0.1";
      configText = ''
        rocommunity public

        sysLocation Cabinet
        sysContact ${config.security.acme.defaults.email}
      '';
    };
  };
}
