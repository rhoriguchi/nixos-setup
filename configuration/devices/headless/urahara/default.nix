{ pkgs, ... }:
{
  imports = [
    ../common.nix

    ./broken-emmc.nix
    ./derper.nix
    ./dhcp
    ./dns
    ./firewall.nix
    ./interfaces.nix
    ./networking.nix
    ./unifi.nix
    ./web-proxy.nix

    ./hardware-configuration.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking.hostName = "XXLPitu-Urahara";

  services = {
    infomaniak.enableIPv6 = true;

    netdata.configDir."go.d/ping.conf" = pkgs.writers.writeYAML "ping.conf" {
      jobs = [
        {
          name = "dns";
          update_every = 10;
          autodetection_retry = 5;
          hosts = [
            "1.1.1.1"
            "8.8.8.8"
            "9.9.9.9"
          ];
        }
        {
          name = "internet";
          update_every = 10;
          autodetection_retry = 5;
          hosts = [
            "bbc.co.uk"
            "digitec.ch"
            "youtube.com"
          ];
        }
      ];
    };
  };
}
