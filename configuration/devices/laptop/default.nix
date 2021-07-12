{ pkgs, lib, ... }: {
  imports = [
    ../../rhoriguchi

    ./rsnapshot.nix
    ./power-management.nix

    ./hardware-configuration.nix
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  networking = {
    hostName = "Ryan-Laptop";

    interfaces = {
      eno2.useDHCP = true; # Ethernet
      wlo1.useDHCP = true; # WiFi
    };
  };

  hardware = {
    bluetooth.enable = true;

    nvidia = {
      modesetting.enable = true;

      prime = {
        offload.enable = true;

        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };

    logitech.wireless = {
      enable = true;
      enableGraphical = true;
    };

    openrazer.enable = true;
  };

  virtualisation.docker.enable = true;

  console.useXkbConfig = true;

  services = {
    resilio = {
      enable = true;

      webUI = {
        enable = true;

        username = "admin";
        password = (import ../../secrets.nix).services.resilio.webUI.password;
      };

      syncPath = "/media/Data/Sync";
    };

    teamviewer.enable = true;

    xserver = {
      enable = true;

      layout = "ch";
      xkbModel = "pc105";
      xkbVariant = "de_nodeadkeys";

      displayManager = {
        gdm = {
          enable = true;
          wayland = false;
        };

        sessionCommands = "${lib.getBin pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource 2 0";
      };

      desktopManager.gnome.enable = true;

      libinput.enable = true;

      videoDrivers = [ "displaylink" "modesetting" "nvidia" ];
    };

    gnome = {
      chrome-gnome-shell.enable = false;
      gnome-initial-setup.enable = false;
      gnome-online-accounts.enable = false;
    };

    udev.packages = [ pkgs.gnome.gnome-settings-daemon ];

    power-profiles-daemon.enable = false;

    onedrive.enable = true;
  };

  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    java.enable = true;

    npm.enable = true;

    steam.enable = true;
  };

  environment = {
    gnome.excludePackages = [
      pkgs.gnome-connections
      pkgs.gnome-photos
      pkgs.gnome.epiphany
      pkgs.gnome.geary
      pkgs.gnome.gnome-calendar
      pkgs.gnome.gnome-characters
      pkgs.gnome.gnome-clocks
      pkgs.gnome.gnome-contacts
      pkgs.gnome.gnome-font-viewer
      pkgs.gnome.gnome-maps
      pkgs.gnome.gnome-music
      pkgs.gnome.gnome-screenshot
      pkgs.gnome.gnome-shell-extensions
      pkgs.gnome.gnome-terminal
      pkgs.gnome.gnome-weather
      pkgs.gnome.simple-scan
      pkgs.gnome.totem
      pkgs.gnome.yelp
    ];

    variables.TERMINAL = "alacritty";

    systemPackages = [
      pkgs.alacritty
      pkgs.ansible_2_10
      pkgs.busybox
      pkgs.curl
      pkgs.discord
      pkgs.docker-compose
      pkgs.firefox
      pkgs.flameshot
      pkgs.gimp
      pkgs.git
      pkgs.git-crypt
      pkgs.gitkraken
      pkgs.glances
      pkgs.gnome.dconf-editor
      pkgs.gnome.networkmanager-openconnect
      pkgs.google-chrome
      pkgs.haskellPackages.nixfmt
      pkgs.htop
      pkgs.inkscape
      pkgs.jetbrains.datagrip
      pkgs.jetbrains.idea-ultimate
      pkgs.jetbrains.pycharm-professional
      pkgs.jetbrains.webstorm
      pkgs.keepass
      pkgs.libreoffice-fresh
      pkgs.maven
      pkgs.neofetch
      pkgs.nodejs
      pkgs.nodePackages."@angular/cli"
      pkgs.ntfs3g
      pkgs.openssl
      pkgs.pipenv
      pkgs.postgresql_13
      pkgs.postman
      pkgs.protonvpn-cli
      pkgs.python3
      pkgs.python3Packages.pip
      pkgs.qbittorrent
      pkgs.signal-desktop
      pkgs.spotify
      pkgs.sshpass
      pkgs.terraform_1_0_0
      pkgs.unzip
      pkgs.vlc
      pkgs.vscode
      pkgs.yarn
    ];
  };

  users.users.rhoriguchi = {
    extraGroups = [ "docker" "networkmanager" "plugdev" "rslsync" "wheel" ];
    isNormalUser = true;
    password = (import ../../secrets.nix).users.users.rhoriguchi.password;
  };
}
