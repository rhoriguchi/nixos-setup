{ pkgs, lib, config, secrets, ... }: {
  imports = [
    ../../common.nix

    ./keepassxc.nix
    ./rsnapshot.nix

    ./hardware-configuration.nix
  ];

  boot = {
    # TODO remove once displaylink and nvidia-x11 build
    # https://github.com/NixOS/nixpkgs/issues/357643
    kernelPackages = pkgs.linuxPackages_6_11;

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 32 * 1024;
  }];

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

      networks = lib.recursiveUpdate secrets.wifis {
        "63466727".priority = 100;
        Niflheim.priority = 10;
      };
    };
  };

  hardware = {
    bluetooth.enable = true;

    logitech.wireless = {
      enable = true;
      enableGraphical = true;
    };

    openrazer.enable = true;

    printers = {
      ensureDefaultPrinter = "Home";

      ensurePrinters = [{
        name = "Home";

        deviceUri = "ipp://XXLPitu-Ulquiorra.local/printers/Default";
        location = "Home";
        model = "raw";
      }];
    };
  };

  services = {
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

  programs = {
    steam.enable = true;

    virt-manager.enable = true;
  };

  environment.systemPackages = [ pkgs.google-chrome pkgs.libreoffice-fresh pkgs.vlc pkgs.wpa_supplicant_gui ];

  users.users = {
    rhoriguchi = {
      extraGroups = [ "networkmanager" "openrazer" "plugdev" "podman" "wheel" ];
      isNormalUser = true;
      password = secrets.users.rhoriguchi.password;

      packages = [
        pkgs.discord
        pkgs.gimp
        pkgs.gitkraken
        pkgs.glow
        pkgs.inkscape
        pkgs.jetbrains.datagrip
        pkgs.jetbrains.idea-ultimate
        pkgs.jetbrains.pycharm-professional
        pkgs.jetbrains.webstorm
        pkgs.obsidian
        pkgs.protonvpn-gui
        pkgs.qbittorrent
        pkgs.signal-desktop
      ];
    };

    sillert = {
      extraGroups = [ "networkmanager" "openrazer" "plugdev" ];
      isNormalUser = true;
      password = secrets.users.sillert.password;
    };
  };

  system.activationScripts.rhoriguchiSetup = let
    home = config.users.users.rhoriguchi.home;
    syncPath = "${home}/Sync";

    downloadDirs = map (path: "'${home}/Downloads/${path}'") [ "Browser" "Torrent" ];

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
