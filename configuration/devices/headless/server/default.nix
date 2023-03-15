{ pkgs, config, lib, public-keys, secrets, ... }: {
  imports = [
    ../common.nix

    ./fancontrol.nix
    ./home-assistant
    ./home-page.nix
    ./libvirtd
    ./price-tracker-proxy.nix
    ./rsnapshot.nix
    ./sonarr

    ./hardware-configuration.nix
  ];

  boot = {
    # TODO remove when zfs is not marked broken
    kernelPackages = pkgs.linuxPackages_5_15;

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  networking = {
    hostId = "c270d3cf";
    hostName = "XXLPitu-Server";

    interfaces = {
      # TODO commented
      # enp5s0.useDHCP = true;
      enp6s0.useDHCP = true;
      # TODO commented
      # wlp4s0.useDHCP = true;
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

      readWriteDirs = lib.attrNames secrets.resilio.secrets;
      secrets = secrets.resilio.secrets;
      syncPath = "/var/lib/Sync";
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
            rev = "v7.4.0";
            hash = "sha256-EUD09H9ftCFm+pgIuyolrLCD6LbC8gZMZ5A875pbnb8=";
          };
        })
      ];
      extraScanners = [
        (pkgs.fetchFromGitHub {
          owner = "ZeroQI";
          repo = "Absolute-Series-Scanner";
          rev = "100c5081adcc928b4c23f2ad51c5aee8ba64eb0a";
          hash = "sha256-wzpI2f8YrjOUCyNFPBeUTLuZV4wpqr6oi4cWBs4MbOk=";
        })
      ];
    };

    tautulli.enable = true;

    wireguard-network = {
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
