{ config, lib, pkgs, secrets, ... }: {
  imports = [
    ../../common.nix

    ./keepassxc.nix
    ./rsnapshot.nix

    ./hardware-configuration.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 32 * 1024;
  }];

  networking = {
    hostName = "Ryan-Laptop";

    interfaces.wlp0s20f3.useDHCP = true; # WiFi

    networkmanager.unmanaged = [ "wlp0s20f3" ];

    wireless = {
      enable = true;

      userControlled.enable = true;
      extraConfig = ''
        p2p_disabled=1
      '';

      networks = lib.recursiveUpdate (lib.mapAttrs (key: value:
        value // {
          extraConfig = lib.concatStringsSep "\n" (lib.catAttrs "extraConfig" [ value ]
            ++ [ (if (lib.elem key [ "63466727" "63466727-IoT" "63466727-Guest" "Niflheim" ]) then "mac_addr=0" else "mac_addr=2") ]);
        }) secrets.wifis) {
          "63466727".priority = 100;
          Niflheim.priority = 10;
        };
    };
  };

  hardware = {
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

    onedrive.enable = true;
  };

  programs = {
    steam = {
      enable = true;
      localNetworkGameTransfers.openFirewall = true;
      remotePlay.openFirewall = true;
    };

    bazecor.enable = true;
  };

  environment.systemPackages = [ pkgs.google-chrome pkgs.libreoffice-fresh pkgs.vlc pkgs.wpa_supplicant_gui ];

  users.users.rhoriguchi = {
    extraGroups = [ "networkmanager" "plugdev" "wheel" ] ++ (lib.optional config.hardware.openrazer.enable "openrazer")
      ++ (lib.optional config.programs.wireshark.enable "wireshark") ++ (lib.optional config.virtualisation.docker.enable "docker")
      ++ (lib.optionals config.virtualisation.libvirtd.enable [ "kvm" "libvirtd" ])
      ++ (lib.optional config.virtualisation.podman.enable "podman")
      ++ (lib.optional config.virtualisation.virtualbox.host.enable "vboxusers");
    isNormalUser = true;
    password = secrets.users.rhoriguchi.password;
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
