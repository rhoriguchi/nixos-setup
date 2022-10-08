{ pkgs, config, lib, public-keys, secrets, ... }: {
  imports = [
    ../common.nix

    ./fancontrol.nix
    ./home-assistant
    ./libvirtd
    ./rsnapshot.nix

    ./hardware-configuration.nix
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=194405
    kernelPackages = pkgs.linuxPackages_5_15;

    supportedFilesystems = [ "zfs" ];
  };

  networking = {
    hostId = "c270d3cf";
    hostName = "XXLPitu-Server";

    interfaces = {
      enp5s0.useDHCP = true;
      enp6s0.useDHCP = true;
      wlp4s0.useDHCP = true;
    };
  };

  services = {
    infomaniak = {
      enable = true;

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
      hostnames = [ "home-assistant.00a.ch" "home.00a.ch" ];
    };

    zfs = {
      expandOnBoot = "all";
      autoScrub.enable = true;
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

      readWriteDirs = lib.attrNames secrets.resilio.secrets;
      secrets = secrets.resilio.secrets;
      syncPath = "/mnt/Data/Sync";
    };

    tv_time_export = {
      enable = true;

      username = secrets.tvTime.username;
      password = secrets.tvTime.password;
      exportPath = "${config.services.resilio.syncPath}/tv_time_export";
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
            rev = "v7.3.1";
            hash = "sha256-3/vJWt6S6ZkM9lmVNvETvxxDjTP+c3gcQ0oUeeRwSKM=";
          };
        })
      ];
      extraScanners = [
        (pkgs.fetchFromGitHub {
          owner = "ZeroQI";
          repo = "Absolute-Series-Scanner";
          rev = "4ef18a738c6263a8b96ab6f83ae391d4550b9cc9";
          hash = "sha256-2bdp0e5XES/phLLUP2mngwITUWdZIE6Y6ness86xSNI=";
        })
      ];
    };

    tautulli = {
      enable = true;

      openFirewall = true;
    };

    wireguard-vpn = {
      enable = true;

      type = "server";
    };
  };

  users.users.gitlab-ci = {
    isNormalUser = true;
    group = "docker";
    hashedPassword = "*";
    openssh.authorizedKeys.keys = [ public-keys.gitlab ];
  };
}
