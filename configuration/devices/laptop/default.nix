{ config, pkgs, lib, ... }:
with lib;
let
  dataDir = "/media/Data";
  syncDir = "${dataDir}/Sync";
in {
  imports = [
    # TODO needs to be generated and replaced
    ./hardware-configuration.nix

    ./rhoriguchi
    # TODO commented
    # ./power-managment.nix
  ];
  
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  nix.autoOptimiseStore = true;

  virtualisation.docker = {
    enable = true;
    enableNvidia = true;
  };

  networking = {
    hostName = "RYAN-LAPTOP";

    interfaces.eno2.useDHCP = true;
    interfaces.wlo1.useDHCP = true;

    networkmanager.unmanaged =
      builtins.attrNames config.networking.wireless.networks;

    wireless.enable = true;
  };

  # TODO get drivers for function buttons
  # https://www.digitec.ch/en/s1/product/asus-vivobook-pro-15-n580gd-e4287t-1560-full-hd-intel-core-i7-8750h-16gb-256gb-2000gb-ssd-hdd-notebo-8850945
  # https://github.com/torvalds/linux/blob/master/drivers/platform/x86/asus-nb-wmi.c

  # TODO figur out ProtonVPN

  hardware = {
    bluetooth.enable = true;

    nvidia.prime = {
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # TODO fomrat drive
  # fileSystems."${dataDir}" = {
  #   # TODO use /dev/disk/by-partuuid
  #   device = "/dev/disk/by-uuid/8b0f2c45-5560-4503-a72c-ff354e4fdb70";
  #   fsType = "ext4";
  #   options = [ "defaults" "nofail" ];
  # };

  # TODO gnome default language is fucked up, login screen as example

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

      drivers = [ pkgs.hplip ];
    };

    xserver = {
      enable = true;

      layout = "ch";
      xkbModel = "pc105";
      xkbVariant = "de_nodeadkeys";

      displayManager = {
        gdm.enable = true;

        sessionCommands = "${
            lib.getBin pkgs.xorg.xrandr
          }/bin/xrandr --setprovideroutputsource 2 0";
      };

      desktopManager.gnome3.enable = true;

      videoDrivers = [ "displaylink" "modesetting" "nvidia" ];
    };

    gnome3 = {
      chrome-gnome-shell.enable = false;
      gnome-initial-setup.enable = mkForce false;
    };
  };

  programs = {
    dconf.enable = true;

    java = {
      enable = true;
      package = pkgs.jdk14;
    };

    steam.enable = true;
  };

  environment = {
    # TODO remove xterm desktop icon
    gnome3.excludePackages = (with pkgs; [ gnome-connections gnome-photos ])
      ++ (with pkgs.gnome3; [
        eog
        geary
        gedit
        gnome-characters
        gnome-clocks
        gnome-contacts
        gnome-font-viewer
        gnome-maps
        gnome-music
        gnome-screenshot
        gnome-terminal
        gnome-weather
        seahorse
        simple-scan
        totem
        yelp
      ]);

    sessionVariables.TERMINAL = "alacritty";

    systemPackages = (with pkgs; [
      alacritty
      ansible
      curl
      discord
      displaylink
      docker-compose
      etcher
      firefox
      flameshot
      gimp
      git
      git-crypt
      gnufdisk
      gitkraken
      gnupg
      google-chrome
      htop
      keepass
      libreoffice-fresh
      maven
      megasync
      neofetch
      nodejs
      openssl
      parted
      postgresql
      postman
      python3
      qbittorrent
      spotify
      terraform
      virtualboxWithExtpack
      vlc
      vscode
    ]) ++ (with pkgs.gnome3; [ adwaita-icon-theme dconf-editor nautilus ])
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
}
