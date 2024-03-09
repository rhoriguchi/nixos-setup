{ pkgs, config, lib, secrets, ... }: {
  imports = [
    ../common.nix

    ./adguardhome.nix
    ./fancontrol.nix
    ./home-assistant
    ./libvirtd
    ./minecraft-server.nix
    ./rsnapshot.nix
    ./sonarr
    ./tautulli.nix

    ./hardware-configuration.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    hostId = "c270d3cf";
    hostName = "XXLPitu-Server";

    interfaces = {
      eno1.useDHCP = true;
      wlp10s0.useDHCP = true;
    };
  };

  services = {
    infomaniak = {
      enable = true;

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
      hostnames = [ "home.00a.ch" ];
    };

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

    wireguard-network = {
      enable = true;
      type = "server";
    };
  };
}
