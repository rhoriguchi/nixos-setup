{ config, lib, pkgs, secrets, ... }: {
  imports = [
    ../common.nix

    ./backup.nix
    ./fancontrol.nix
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

      device = "nodev";

      mirroredBoots = [{
        devices = [ "/dev/disk/by-uuid/6054-F72D" ];
        path = "/boot-mirror";
      }];
    };

    # TODO unpin once zfs works with latest kernel
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
