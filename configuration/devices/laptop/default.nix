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
      enp0s20f0u4u3u1.useDHCP = true; # Icy Box IB-DK2106-C
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

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

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

      desktopManager.gnome3.enable = true;

      libinput.enable = true;

      videoDrivers = [ "displaylink" "modesetting" "nvidia" ];
    };

    gnome3 = {
      chrome-gnome-shell.enable = false;
      gnome-initial-setup.enable = lib.mkForce false;
      gnome-online-accounts.enable = lib.mkForce false;
    };

    udev.packages = [ pkgs.gnome3.gnome-settings-daemon ];

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
    gnome3.excludePackages = [
      pkgs.gnome-connections
      pkgs.gnome-photos
      pkgs.gnome3.epiphany
      pkgs.gnome3.geary
      pkgs.gnome3.gnome-calendar
      pkgs.gnome3.gnome-characters
      pkgs.gnome3.gnome-clocks
      pkgs.gnome3.gnome-contacts
      pkgs.gnome3.gnome-font-viewer
      pkgs.gnome3.gnome-maps
      pkgs.gnome3.gnome-music
      pkgs.gnome3.gnome-screenshot
      pkgs.gnome3.gnome-shell-extensions
      pkgs.gnome3.gnome-terminal
      pkgs.gnome3.gnome-weather
      pkgs.gnome3.simple-scan
      pkgs.gnome3.totem
      pkgs.gnome3.yelp
    ];

    variables.TERMINAL = "alacritty";

    systemPackages = [
      pkgs.alacritty
      pkgs.ansible
      pkgs.ansible
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
      pkgs.gnome3.dconf-editor
      pkgs.gnome3.networkmanager-openconnect
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
      pkgs.postgresql_12
      pkgs.postman
      pkgs.protonvpn-cli
      pkgs.python3
      pkgs.python3Packages.pip
      pkgs.qbittorrent
      pkgs.signal-desktop
      pkgs.spotify
      pkgs.sshpass
      pkgs.terraform_0_15
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
