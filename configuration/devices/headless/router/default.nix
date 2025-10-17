{
  config,
  lib,
  pkgs,
  ...
}:
let
  tailscaleIps = import (
    lib.custom.relativeToRoot "configuration/devices/headless/router/headscale/ips.nix"
  );
  filteredTailscaleIps = lib.filterAttrs (
    key: _:
    !(lib.elem key [
      osConfig.networking.hostName
      "headplane-agent"
    ])
  ) tailscaleIps;
in
{
  imports = [
    ../common.nix

    ./broken-emmc.nix
    ./dhcp
    ./dns
    ./firewall.nix
    ./headscale
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

  networking.hostName = "XXLPitu-Router";

  services.netdata.configDir."go.d/ping.conf" = pkgs.writers.writeYAML "ping.conf" {
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
      {
        name = "tailscale";
        update_every = 10;
        autodetection_retry = 5;
        interface = config.services.tailscale.interfaceName;
        hosts = lib.attrValues (
          lib.filterAttrs (key: _: key != config.networking.hostName) filteredTailscaleIps
        );
      }
    ];
  };
}
