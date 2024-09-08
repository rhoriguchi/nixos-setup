{ pkgs, config, lib, secrets, ... }: {
  imports = [
    ../common.nix

    ./backup.nix
    ./fancontrol.nix
    ./home-assistant
    ./libvirtd
    ./log-management.nix
    ./monitoring.nix
    ./sonarr
    ./tautulli.nix

    ./hardware-configuration.nix
  ];

  # TODO remove when zfs is not marked broken
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_6;

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    hostId = "c270d3cf";
    hostName = "XXLPitu-Server";

    # TODO breaks libvirt guest internet
    nftables.enable = lib.mkForce false;

    interfaces = {
      eno1.useDHCP = true;
      wlp10s0.useDHCP = true;
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

      readWriteDirs = lib.remove "Obsidian_Work" (lib.attrNames secrets.resilio.secrets);
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
    };
  };
}
