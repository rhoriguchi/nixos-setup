{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../common.nix

    ./arr
    ./authelia
    ./backup.nix
    ./couchdb.nix
    ./fancontrol.nix
    ./nvidia-quadro-rtx-5000.nix
    ./grafana
    ./home-assistant
    ./jellyfin.nix
    ./loki.nix
    ./metric-scrapers
    ./minecraft-server
    ./monitoring.nix
    ./plex
    ./prometheus.nix
    ./rustdesk.nix
    ./samba.nix
    ./syncthing-relay.nix
    ./terraria.nix
    ./webdav.nix

    ./hardware-configuration.nix
  ];

  boot = {
    loader.grub = {
      enable = true;

      efiSupport = true;
      efiInstallAsRemovable = true;

      devices = lib.mkForce [ ];
      mirroredBoots = [
        {
          devices = [ "nodev" ];
          path = "/boot1";
        }
        {
          devices = [ "nodev" ];
          path = "/boot2";
        }
      ];
    };

    kernelPackages = pkgs.linuxPackages;
  };

  networking = {
    hostId = "c270d3cf";
    hostName = "XXLPitu-Tier";

    interfaces = {
      eno1.useDHCP = true;
      wlp11s0.useDHCP = true;
    };

    firewall.allowedTCPPorts = [
      config.services.nginx.defaultHTTPListenPort
      config.services.nginx.defaultSSLListenPort
    ];
  };

  services.custom-syncthing.syncDir = "/mnt/Data/Sync";
}
