{ config, lib, pkgs, secrets, ... }: {
  imports = [
    ../common.nix

    ./backup.nix
    ./fancontrol.nix
    ./gphotos-sync.nix
    ./home-assistant
    ./immich.nix
    ./log-management.nix
    ./minecraft-server.nix
    ./monitoring.nix
    ./plex.nix
    ./sonarr
    ./tautulli.nix

    ./hardware-configuration.nix
  ];

  boot = {
    loader.grub = {
      enable = true;

      efiSupport = true;
      efiInstallAsRemovable = true;

      device = "nodev";

      mirroredBoots = [{
        devices = [ "/dev/disk/by-uuid/6054-F72D" ];
        path = "/boot-mirror";
      }];
    };

    kernelPackages = pkgs.linuxPackages;
  };

  networking = {
    hostId = "c270d3cf";
    hostName = "XXLPitu-Server";

    interfaces = {
      eno1.useDHCP = true;
      wlp11s0.useDHCP = true;
    };

    firewall.allowedTCPPorts = [ config.services.nginx.defaultHTTPListenPort config.services.nginx.defaultSSLListenPort ];
  };

  services.resilio = {
    enable = true;

    readWriteDirs = lib.attrNames secrets.resilio.secrets;
    secrets = secrets.resilio.secrets;
    syncPath = "/mnt/Data/Sync";
  };
}
