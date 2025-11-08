{
  config,
  lib,
  pkgs,
  secrets,
  ...
}:
{
  imports = [
    ../common.nix

    ./backup.nix
    ./fancontrol.nix
    ./geforce-gt-730.nix
    ./home-assistant
    ./log-management
    ./minecraft-server
    ./monitoring.nix
    ./plex.nix
    ./rustdesk.nix
    ./samba.nix
    ./sonarr
    ./tautulli.nix

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

  services.resilio = {
    enable = true;

    readWriteDirs = lib.attrNames secrets.resilio.secrets;
    secrets = secrets.resilio.secrets;
    syncPath = "/mnt/Data/Sync";
  };
}
