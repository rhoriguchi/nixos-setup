{ pkgs, lib, config, ... }: {
  imports = [
    ../../rhoriguchi
    ../../displaylink.nix

    ./highdpi.nix
    ./lenovo-legion-s7-15ach6.nix
    ./nvidia.nix
    ./rsnapshot.nix
    ./power-management.nix

    ./hardware-configuration.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = "Ryan-Laptop";

    interfaces = {
      wlp2s0.useDHCP = true; # WiFi
    };

    networkmanager.unmanaged = [ "wlp2s0" ];

    wireless = {
      enable = true;
      userControlled.enable = true;
      extraConfig = ''
        p2p_disabled=1
      '';

      networks = (import ../../secrets.nix).networking.wireless.networks;
    };
  };

  hardware = {
    bluetooth.enable = true;

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

      syncPath = "/srv/Sync";
    };

    teamviewer.enable = true;

    xserver = {
      enable = true;

      layout = "ch";
      xkbModel = "pc105";
      xkbVariant = "de_nodeadkeys";

      displayManager.gdm = {
        enable = true;
        wayland = false;
      };

      desktopManager.gnome.enable = true;

      libinput.enable = true;
    };

    gnome = {
      chrome-gnome-shell.enable = false;
      gnome-initial-setup.enable = false;
      gnome-online-accounts.enable = false;
    };

    udev.packages = [ pkgs.gnome.gnome-settings-daemon ];

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
      pkgs.gnome.gnome-logs
      pkgs.gnome.gnome-maps
      pkgs.gnome.gnome-music
      pkgs.gnome.gnome-screenshot
      pkgs.gnome.gnome-terminal
      pkgs.gnome.gnome-weather
      pkgs.gnome.simple-scan
      pkgs.gnome.totem
      pkgs.gnome.yelp
    ];

    variables.TERMINAL = "alacritty";

    systemPackages = [
      pkgs.alacritty
      pkgs.curl
      pkgs.discord
      pkgs.docker-compose
      pkgs.file
      pkgs.firefox
      pkgs.flameshot
      pkgs.gimp
      pkgs.git
      pkgs.git-crypt
      pkgs.git-lfs
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
      pkgs.keepassxc
      pkgs.libreoffice-fresh
      pkgs.maven
      pkgs.neofetch
      pkgs.nodejs
      pkgs.openssl
      pkgs.pipenv
      pkgs.postgresql
      pkgs.postman
      pkgs.protonvpn-gui
      pkgs.python3
      pkgs.python3Packages.pip
      pkgs.qbittorrent
      pkgs.signal-desktop
      pkgs.spotify-unwrapped
      pkgs.sshpass
      pkgs.terraform
      pkgs.tree
      pkgs.unzip
      pkgs.vlc
      pkgs.vscode
      pkgs.wpa_supplicant_gui
      pkgs.yarn
    ];
  };

  users.users.rhoriguchi = {
    extraGroups = [ "docker" "networkmanager" "plugdev" "rslsync" "wheel" ];
    isNormalUser = true;
    password = (import ../../secrets.nix).users.users.rhoriguchi.password;
  };

  system.activationScripts.rhoriguchiSetup = let
    home = config.users.users.rhoriguchi.home;
    syncPath = config.services.resilio.syncPath;

    downloadDirs = map (path: ''"${home}/Downloads/${path}"'') [ "Browser" "Torrent" ];

    createSymlink = source: target: ''
      if [ -d "${source}" ] && [ ! \( -L "${target}" \) ] && [ ! \( -e "${target}" \) ]; then
        rm -rf "${target}"
        ln -sf "${source}" "${target}"
      fi
    '';
  in ''
    mkdir -p ${lib.concatStringsSep " " downloadDirs}
    chown -R rhoriguchi:${config.users.users.rhoriguchi.group} ${lib.concatStringsSep " " downloadDirs}

    ${createSymlink "${syncPath}/Git" "${home}/Git"}
    ${createSymlink "${syncPath}/Storage/Inspiration" "${home}/Documents/Inspiration"}
    ${createSymlink "${syncPath}/Storage/Recipes" "${home}/Documents/Recipes"}
  '';
}
