{ config, pkgs, lib, ... }:
with lib;
let
  dataDir = "/media/Data";
  syncDir = "${dataDir}/Sync";
in {
  imports = [
    # TODO figure out how to import this from github
    <home-manager/nixos>

    ./hardware-configuration.nix

    ./power-management.nix
    ./rhoriguchi
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  nix.autoOptimiseStore = true;

  virtualisation = {
    docker = {
      enable = true;
      enableNvidia = true;
    };

    virtualbox.host = {
      enable = true;
      enableExtensionPack = true;
    };
  };

  networking = {
    hostName = "RYAN-LAPTOP";

    interfaces = {
      # TODO add "Targus DOCK190EUZ"
      eno2.useDHCP = true;
      enp0s20f0u4u3u1.useDHCP = true; # Icy Box IB-DK2106-C
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
  };

  fileSystems."${dataDir}" = {
    device = "/dev/disk/by-uuid/2ef587d0-6f82-4715-a04f-2d1e6d5c7883";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  };

  system.activationScripts.createDataDir =
    "${pkgs.coreutils}/bin/mkdir -pm 0777 ${dataDir}";

  console.useXkbConfig = true;

  services = {
    resilio = {
      enable = true;
      syncPath = "${syncDir}";
      webUI.enable = true;
    };

    udev.packages = [ pkgs.gnome3.gnome-settings-daemon ];

    teamviewer.enable = true;

    printing = {
      enable = true;

      drivers = with pkgs; [ hplip ];
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
          [org.gnome.shell]
          enabled-extensions=['${pkgs.gnomeExtensions.appindicator.uuid}']

          [org.gnome.desktop.peripherals.touchpad]
          click-method='default'
        '';
      };

      libinput.enable = true;

      videoDrivers = [ "displaylink" "modesetting" "nvidia" ];
    };

    gnome3 = {
      chrome-gnome-shell.enable = false;
      gnome-initial-setup.enable = mkForce false;
    };
  };

  programs = {
    dconf.enable = true;

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    java.enable = true;

    steam.enable = true;
  };

  environment = {
    gnome3.excludePackages = (with pkgs; [ gnome-connections gnome-photos ])
      ++ (with pkgs.gnome3; [
        epiphany
        geary
        gnome-calendar
        gnome-characters
        gnome-clocks
        gnome-contacts
        gnome-font-viewer
        gnome-maps
        gnome-music
        gnome-screenshot
        gnome-shell-extensions
        gnome-weather
        seahorse
        simple-scan
        totem
        yelp
      ]);

    systemPackages = (with pkgs; [
      ansible_2_9
      bind
      binutils-unwrapped
      curl
      discord
      displaylink
      docker-compose
      firefox
      flameshot
      gimp
      git
      git-crypt
      gitkraken
      gnupg
      google-chrome
      htop
      keepass
      libreoffice-fresh
      lsb-release
      maven
      megasync
      neofetch
      nodejs
      ntfs3g
      openssl
      parted
      postgresql_12
      postman
      protonvpn-cli
      python3
      qbittorrent
      signal-desktop
      spotify
      sshpass
      terraform_0_14
      unzip
      vlc
      vscode
    ]) ++ (with pkgs.gnome3; [ dconf-editor networkmanager-openconnect ])
      ++ (with pkgs.gnomeExtensions; [ appindicator ])
      ++ (with pkgs.haskellPackages; [ nixfmt ]) ++ (with pkgs.jetbrains; [
        datagrip
        idea-ultimate
        pycharm-professional
        webstorm
      ]) ++ (with pkgs.nodePackages; [ npm prettier ])
      ++ (with pkgs.python38Packages; [
        flake8
        mypy
        pip
        pylint
        pytest
        pytest_xdist
      ]) ++ (with pkgs.unixtools; [ ifconfig ]);
  };

  users.users = {
    gdavoli.isNormalUser = true;

    rhoriguchi = {
      extraGroups = [ "docker" "networkmanager" "rslsync" "vboxusers" "wheel" ];
      isNormalUser = true;
    };
  };
}
