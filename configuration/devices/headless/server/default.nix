{ config, lib, secrets, ... }: {
  imports = [
    ../common.nix

    ./backup.nix
    ./fancontrol.nix
    ./gphotos-sync.nix
    ./home-assistant
    ./immich.nix
    ./libvirtd
    ./log-management.nix
    ./minecraft-server.nix
    ./monitoring.nix
    ./plex.nix
    ./sonarr
    ./tautulli.nix

    ./hardware-configuration.nix
  ];

  boot.loader.grub = {
    enable = true;

    zfsSupport = true;
    efiSupport = true;
    efiInstallAsRemovable = true;

    device = "nodev";

    mirroredBoots = [{
      devices = [ "/dev/disk/by-uuid/6054-F72D" ];
      path = "/boot-mirror";
    }];
  };

  networking = {
    hostId = "c270d3cf";
    hostName = "XXLPitu-Server";

    # TODO breaks libvirt guest internet
    nftables.enable = lib.mkForce false;

    interfaces = {
      eno1.useDHCP = true;
      wlp11s0.useDHCP = true;
    };

    firewall.allowedTCPPorts = [ config.services.nginx.defaultHTTPListenPort config.services.nginx.defaultSSLListenPort ];
  };

  services = {
    resilio = {
      enable = true;

      readWriteDirs = lib.attrNames secrets.resilio.secrets;
      secrets = secrets.resilio.secrets;
      syncPath = "/mnt/Data/Sync";
    };

    monitoring = lib.mkForce {
      enable = true;

      type = "parent";
      apiKey = secrets.monitoring.apiKey;
      discordWebhookUrl = secrets.monitoring.discordWebhookUrl;
    };
  };
}
