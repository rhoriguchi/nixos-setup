{ config, pkgs, lib, ... }:
let
  dataDir = "/media/Data";
  syncDir = "${dataDir}/Sync";
in {
  imports = [
    ../../users/rhoriguchi

    ./hardware-configuration.nix
    ./power-management.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  nix.autoOptimiseStore = true;

  networking = {
    hostName = "RYAN-LAPTOP";

    interfaces = {
      eno2.useDHCP = true;
      enp0s20f0u4u3u1.useDHCP = true; # Icy Box IB-DK2106-C
      usb0.useDHCP = true; # Targus DOCK190EUZ
      wlo1.useDHCP = true;
    };
  };

  hardware = {
    bluetooth.enable = true;

    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;

      prime = {
        offload.enable = true;

        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };

    openrazer.enable = true;
  };

  fileSystems."${dataDir}" = {
    device = "/dev/disk/by-uuid/2ef587d0-6f82-4715-a04f-2d1e6d5c7883";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  };

  system.activationScripts.createDataDir =
    "${pkgs.coreutils}/bin/mkdir -pm 0777 ${dataDir}";

  virtualisation.docker.enable = true;

  console.useXkbConfig = true;

  services = {
    resilio = {
      enable = true;
      syncPath = "${syncDir}";
      webUI.enable = true;
    };

    teamviewer.enable = true;

    printing = {
      enable = true;

      drivers = [ pkgs.hplip ];
      webInterface = false;
    };

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

        sessionCommands = "${
            lib.getBin pkgs.xorg.xrandr
          }/bin/xrandr --setprovideroutputsource 2 0";
      };

      desktopManager.gnome3 = {
        enable = true;

        extraGSettingsOverrides = ''
          [org.gnome.desktop.peripherals.touchpad]
          click-method='default'
        '';
      };

      libinput.enable = true;

      videoDrivers = [ "displaylink" "modesetting" "nvidia" ];
    };

    gnome3 = {
      chrome-gnome-shell.enable = false;
      gnome-initial-setup.enable = lib.mkForce false;
    };
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
      pkgs.gnome3.seahorse
      pkgs.gnome3.simple-scan
      pkgs.gnome3.totem
      pkgs.gnome3.yelp
    ];

    sessionVariables.TERMINAL = "alacritty";

    systemPackages = [
      pkgs.alacritty
      pkgs.bind
      pkgs.binutils-unwrapped
      pkgs.curl
      pkgs.discord
      pkgs.displaylink
      pkgs.docker-compose
      pkgs.firefox
      pkgs.flameshot
      pkgs.gimp
      pkgs.git
      pkgs.git-crypt
      pkgs.gitkraken
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
      pkgs.lsb-release
      pkgs.maven
      pkgs.megasync
      pkgs.neofetch
      pkgs.nodejs
      pkgs.nodePackages."@angular/cli"
      pkgs.ntfs3g
      pkgs.openssl
      pkgs.parted
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
      pkgs.terraform_0_14
      pkgs.unixtools.ifconfig
      pkgs.unzip
      pkgs.vlc
      pkgs.vscode
      pkgs.yarn
    ];
  };

  users.users = {
    gdavoli.isNormalUser = true;

    rhoriguchi = {
      extraGroups =
        [ "docker" "networkmanager" "plugdev" "rslsync" "vboxusers" "wheel" ];
      isNormalUser = true;
    };
  };
}
