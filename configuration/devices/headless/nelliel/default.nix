{ config, ... }:
{
  imports = [
    ../common.nix

    ./headscale
    ./uptime-kuma.nix

    ./hardware-configuration.nix
  ];

  boot.loader.grub = {
    enable = true;

    device = "/dev/sda";
  };

  networking = {
    hostName = "XXLPitu-Nelliel";

    interfaces.enp1s0 = {
      useDHCP = true;

      ipv6.addresses = [
        {
          address = "2a01:4f8:1c1a:6e76::";
          prefixLength = 64;
        }
      ];
    };

    defaultGateway6 = {
      address = "fe80::1";
      interface = "enp1s0";
    };

    firewall.allowedTCPPorts = [
      config.services.nginx.defaultSSLListenPort
      config.services.nginx.defaultHTTPListenPort
    ];
  };
}
