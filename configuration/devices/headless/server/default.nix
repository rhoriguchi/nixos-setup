{ pkgs, config, lib, public-keys, secrets, ... }: {
  imports = [
    ../common.nix

    ./fancontrol.nix
    ./home-assistant
    ./libvirtd
    ./rsnapshot.nix
    ./sonarr

    ./hardware-configuration.nix
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

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
          rev = "9c8ce030d3251951880cd03b925018a475eae2ae";
          hash = "sha256-BQED6Axg1hJU50eLKZzjcyXb1DY4S/W1dzqWt44YPBk=";
        })
      ];
    };

    tautulli.enable = true;

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
