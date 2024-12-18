{ pkgs, config, lib, secrets, ... }: {
  imports = [
    ../common.nix

    ./backup.nix
    ./fancontrol.nix
    ./home-assistant
    ./immich.nix
    ./libvirtd
    ./log-management.nix
    ./monitoring.nix
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
    gphotos-sync = {
      enable = true;

      projectId = secrets.gphotosSync.projectId;
      clientId = secrets.gphotosSync.clientId;
      clientSecret = secrets.gphotosSync.clientSecret;
      exportPath = "${config.services.resilio.syncPath}/Google_Photos";
    };

    resilio = {
      enable = true;

      readWriteDirs = lib.attrNames secrets.resilio.secrets;
      secrets = secrets.resilio.secrets;
      syncPath = "/mnt/Data/Sync";
    };

    plex = {
      enable = true;

      openFirewall = true;

      extraPlugins = [
        (builtins.path {
          name = "MyAnimeList.bundle";
          path = pkgs.fetchFromGitHub {
            owner = "Fribb";
            repo = "MyAnimeList.bundle";
            rev = "v7.4.1";
            hash = "sha256-hqdhz1FyzwgLHcxMRSuSuwNLuqDhdy+t6KCZhESgAho=";
          };
        })
      ];
      extraScanners = [
        (pkgs.fetchFromGitHub {
          owner = "ZeroQI";
          repo = "Absolute-Series-Scanner";
          rev = "ddca35eecb2377e727850e0497bc9b1f67fc11e7";
          hash = "sha256-xMZPSi6+YUNFJjNmiiIBN713A/2PKDuQ1Iwm5c/Qt+s=";
        })
      ];
    };

    monitoring = lib.mkForce {
      enable = true;

      type = "parent";
      apiKey = secrets.monitoring.apiKey;
      discordWebhookUrl = secrets.monitoring.discordWebhookUrl;
    };
  };
}
