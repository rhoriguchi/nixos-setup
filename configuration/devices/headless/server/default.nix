{ pkgs, config, lib, secrets, ... }: {
  imports = [
    ../common.nix

    ./fancontrol
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

  virtualisation.docker = {
    enable = true;

    logDriver = "json-file";
    extraOptions = lib.concatStringsSep " " [ "--log-opt max-file=10" "--log-opt max-size=10m" ];
  };

  services = {
    infomaniak = {
      enable = true;

      username = secrets.services.infomaniak.username;
      password = secrets.services.infomaniak.password;
      hostnames = [ "home-assistant.00a.ch" "home.00a.ch" ];
    };

    zfs = {
      expandOnBoot = "all";
      autoScrub.enable = true;
    };

    gphotos-sync = {
      enable = true;

      projectId = secrets.services.gphotos-sync.projectId;
      clientId = secrets.services.gphotos-sync.clientId;
      clientSecret = secrets.services.gphotos-sync.clientSecret;
      exportPath = "${config.services.resilio.syncPath}/Google_Photos";
    };

    resilio = {
      enable = true;

      readWriteDirs = lib.attrNames secrets.services.resilio.secrets;
      secrets = secrets.services.resilio.secrets;
      syncPath = "/mnt/Data/Sync";
    };

    tv_time_export = {
      enable = true;

      username = secrets.services.tv_time_export.username;
      password = secrets.services.tv_time_export.password;
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
            rev = "v7.2.1";
            hash = "sha256-5F/ILQpvgEEDGFGcxyNkVv9teDT8DEBXSjcFNf1Bdpo=";
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
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDNyfENbLnYf0R+ATrU4zMFHsa87gWDPDH4PLwsm3Qkz67c2T6trCnxmqdIWqXPSu8CN3sHAE0hXHYxUkYNwkDFf2eIEG1BiOXGbYyktXHVjJFDcmZ8uvc1UPlp0m1qcp1g6ZUduroG12H8ltUEkaE5aZomISzalRWQ0Uh8qoWWJsgY7AQXJII+JBLLTx9q3IPYAxXFGjgCJnra8odSx2EmZL9L9A/R0LIQ+BFWjDmjCQ/xxdcMGgYJ0UiAlvour8UZFkhtg9afTTKRZAGpV8FFsp9f2lszpS+1iT9yQaGjCK/xUbuLNn5aKRaOsOlBl+a0kM9/1/O5GsfuniTjJqEr0G5P6VOF3cLDGst4Xbe0TVu9cBYMEsnxkX7Za8XR09hyqGQhpj9WbTOmQNolWjxmJRx4zfaQrlnAJAvEUUTs1y/pxviLGmeSK7nK2N91qlsqHnVWj3ZQexVAOzVGzBaKdnvRndNDeYcpbREvuLhl8itzBpG5+tYlhfJ386f3O4j4+exK9VsOzNBvP+E60bofEwI9T+1PHXO/4RAmrmGoU7UGuSXR96Z+ZgtfTJeetAiH9agTfexo7ncI8Qurzv/emsveLyOGIYut+F5K7qs9MKIvzZaIuOt3QjioGq2/TYVGrpf9TuyV3JcLMz2NPVwwLDuIzHYI5faVkF6figu79w== GitLab"
    ];
  };
}
