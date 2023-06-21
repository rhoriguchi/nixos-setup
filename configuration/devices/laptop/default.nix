{ pkgs, lib, config, secrets, ... }: {
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

      networks = secrets.wifis;
    };
  };

  hardware = {
    bluetooth.enable = true;

    pulseaudio.enable = true;

    logitech.wireless = {
      enable = true;
      enableGraphical = true;
    };

    openrazer.enable = true;
  };

  services = {
    # TODO remove once nvidia works with wayland
    xserver.displayManager = {
      gdm.wayland = false;

      autoLogin.user = "rhoriguchi";
    };

    resilio = {
      enable = true;

      webUI = {
        enable = true;

        username = "admin";
        password = secrets.resilio.webUI.password;
      };
    };

    teamviewer.enable = true;

    onedrive.enable = true;
  };

  programs.steam.enable = true;

  environment.systemPackages = [
    pkgs.discord
    pkgs.gimp
    pkgs.google-chrome
    pkgs.inkscape
    pkgs.jetbrains.datagrip
    pkgs.jetbrains.idea-ultimate
    pkgs.jetbrains.pycharm-professional
    pkgs.jetbrains.webstorm
    pkgs.libreoffice-fresh
    pkgs.neofetch
    pkgs.obsidian
    pkgs.postgresql
    pkgs.protonvpn-gui
    pkgs.qbittorrent
    pkgs.signal-desktop
    pkgs.virt-manager
    pkgs.vlc
    pkgs.vscode
    pkgs.wpa_supplicant_gui
  ];

  users.users.rhoriguchi = {
    extraGroups = [ "networkmanager" "plugdev" "podman" "wheel" ];
    isNormalUser = true;
    password = secrets.users.rhoriguchi.password;
  };

  system.activationScripts.rhoriguchiSetup = let
    home = config.users.users.rhoriguchi.home;
    syncPath = "${home}/Sync";

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
    ${createSymlink "${syncPath}/KeePass" "${home}/Documents/KeePass"}
    ${createSymlink "${syncPath}/Storage/Inspiration" "${home}/Documents/Inspiration"}
    ${createSymlink "${syncPath}/Storage/Recipes" "${home}/Documents/Recipes"}
  '';
}
