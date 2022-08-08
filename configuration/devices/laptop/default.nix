{ pkgs, lib, config, secrets, ... }:
let
  home = config.users.users.rhoriguchi.home;
  syncPath = config.services.resilio.syncPath;
in {
  imports = [
    ./keepassxc.nix
    ./rsnapshot.nix

    ./hardware-configuration.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = "Ryan-Laptop";

    interfaces.wlp2s0.useDHCP = true; # WiFi

    networkmanager.unmanaged = [ "wlp2s0" ];

    wireless = {
      enable = true;

      userControlled.enable = true;
      extraConfig = ''
        p2p_disabled=1
      '';

      networks = secrets.networking.wireless.networks;
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

  security.pam.enableEcryptfs = true;

  services = {
    # TODO remove once nvidia works with wayland
    xserver.displayManager.gdm.wayland = false;

    resilio = {
      enable = true;

      storagePath = "${home}/.resilio-sync";
      syncPath = "${home}/Sync";

      webUI = {
        enable = true;

        username = "admin";
        password = secrets.services.resilio.webUI.password;
      };
    };

    teamviewer.enable = true;

    xserver.libinput.enable = true;

    onedrive.enable = true;
  };

  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    htop.enable = true;

    steam.enable = true;
  };

  environment = {
    variables.TERMINAL = "alacritty";

    systemPackages = [
      pkgs.alacritty
      pkgs.bat
      pkgs.curl
      pkgs.deadnix
      pkgs.discord
      pkgs.file
      pkgs.firefox
      pkgs.flameshot
      pkgs.gimp
      pkgs.git
      pkgs.git-crypt
      pkgs.git-lfs
      pkgs.gitkraken
      pkgs.glances
      pkgs.google-chrome
      pkgs.haskellPackages.nixfmt
      pkgs.inkscape
      pkgs.jetbrains.datagrip
      pkgs.jetbrains.idea-ultimate
      pkgs.jetbrains.pycharm-professional
      pkgs.jetbrains.webstorm
      pkgs.libreoffice-fresh
      pkgs.neofetch
      pkgs.nixfmt
      pkgs.openssl
      pkgs.postgresql
      pkgs.postman
      pkgs.protonvpn-gui
      pkgs.qbittorrent
      pkgs.signal-desktop
      pkgs.spotify-unwrapped
      pkgs.sshpass
      pkgs.terraform
      pkgs.tree
      pkgs.unzip
      pkgs.virt-manager
      pkgs.vlc
      pkgs.vscode
      pkgs.wpa_supplicant_gui
      pkgs.zip
    ];
  };

  users.users.rhoriguchi = {
    extraGroups = [ "networkmanager" "plugdev" "podman" "wheel" ];
    isNormalUser = true;
    password = secrets.users.users.rhoriguchi.password;
  };

  system.activationScripts.rhoriguchiSetup = let
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

    ${createSymlink "${syncPath}/KeePass" "${home}/Documents/KeePass"}
    ${createSymlink "${syncPath}/Storage/Inspiration" "${home}/Documents/Inspiration"}
    ${createSymlink "${syncPath}/Storage/Recipes" "${home}/Documents/Recipes"}
  '';
}
