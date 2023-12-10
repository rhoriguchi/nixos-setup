{ pkgs, config, lib, secrets, ... }: {
  imports = [
    ../common.nix

    ./fancontrol.nix
    ./home-assistant
    ./libvirtd
    ./minecraft-server.nix
    ./rsnapshot.nix
    ./sonarr

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
      hostnames = [ "home.00a.ch" "tautulli.00a.ch" ];
    };

    nginx = {
      enable = true;

      virtualHosts."tautulli.00a.ch" = {
        enableACME = true;
        forceSSL = true;

        locations."/".proxyPass = "http://127.0.0.1:${toString config.services.tautulli.port}";
      };
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
          rev = "bb806978e4f211c59ef6813e7537934a75940f36";
          hash = "sha256-2kxO2jE0/3L46eM46sbmTvza1uBzfYZktAHmLxcfXLY=";
        })
      ];
    };

    tautulli.enable = true;

    wireguard-network = {
      enable = true;
      type = "server";
    };
  };
}
