{
  config,
  lib,
  wifis,
  ...
}:
{
  imports = [
    ../../common.nix

    ./hp-g4.nix
    ./keepassxc.nix
    ./rsnapshot.nix

    ./hardware-configuration.nix
  ];

  sops = {
    secrets =
      lib.listToAttrs (
        map (ssid: lib.nameValuePair "wifis/${ssid}" { }) (lib.attrNames wifis.wirelessNetworks)
      )
      // {
        "nix/settings/access-tokens/github.com" = { };

        "users/rhoriguchi".neededForUsers = true;
        "users/sillert".neededForUsers = true;
      };

    templates = {
      "networking.wireless.secretsFile" = {
        owner = "wpa_supplicant";

        content = lib.concatStrings (
          map (ssid: "${ssid}=${config.sops.placeholder."wifis/${ssid}"}\n") (
            lib.attrNames wifis.wirelessNetworks
          )
        );

        restartUnits = [ config.systemd.services.wpa_supplicant.name ];
      };

      "nix.extraOptions.accessTokens" = {
        group = "wheel";
        mode = "0440";

        content = "access-tokens = ${
          lib.concatStringsSep " " [
            "github.com=${config.sops.placeholder."nix/settings/access-tokens/github.com"}"
          ]
        }";

        restartUnits = [ config.systemd.services.nix-daemon.name ];
      };
    };
  };

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 32 * 1024;
    }
  ];

  nix.extraOptions = ''
    !include ${config.sops.templates."nix.extraOptions.accessTokens".path}
  '';

  networking = {
    hostName = "XXLPitu-Aizen";

    interfaces.wlp0s20f3.useDHCP = true; # WiFi

    networkmanager.unmanaged = [ "wlp0s20f3" ];

    wireless = {
      enable = true;

      userControlled = true;
      extraConfig = ''
        p2p_disabled=1
      '';

      networks = lib.recursiveUpdate wifis.wirelessNetworks {
        "63466727".priority = 100;
        Niflheim.priority = 10;
      };

      secretsFile = config.sops.templates."networking.wireless.secretsFile".path;
    };
  };

  hardware.printers = {
    ensureDefaultPrinter = "Home";

    ensurePrinters = [
      {
        name = "Home";

        deviceUri = "ipp://XXLPitu-Ulquiorra.local/printers/Default";
        location = "Home";
        model = "raw";
      }
    ];
  };

  services = {
    automatic-timezoned.enable = true;

    displayManager.autoLogin.user = "rhoriguchi";

    onedrive.enable = true;

    custom-syncthing = {
      user = "rhoriguchi";
      group = "users";

      syncDir = "${config.users.users.rhoriguchi.home}/Sync";

      trashcan.enable = true;
    };
  };

  programs.gnupg.agent.enable = true;

  users.users = {
    rhoriguchi = {
      extraGroups = [
        "networkmanager"
        "plugdev"

        "wheel"
      ]
      ++ (lib.optional config.hardware.openrazer.enable "openrazer")
      ++ (lib.optional config.networking.wireless.enable "wpa_supplicant")
      ++ (lib.optional config.programs.wireshark.enable "wireshark")
      ++ (lib.optional config.virtualisation.docker.enable "docker")
      ++ (lib.optional config.virtualisation.podman.enable "podman")
      ++ (lib.optional config.virtualisation.virtualbox.host.enable "vboxusers")
      ++ (lib.optionals config.virtualisation.libvirtd.enable [
        "kvm"
        "libvirtd"
      ]);
      isNormalUser = true;
      hashedPasswordFile = config.sops.secrets."users/rhoriguchi".path;
    };

    sillert = {
      extraGroups = [
        "networkmanager"
        "plugdev"
      ]
      ++ (lib.optional config.hardware.openrazer.enable "openrazer")
      ++ (lib.optional config.networking.wireless.enable "wpa_supplicant");
      isNormalUser = true;
      hashedPasswordFile = config.sops.secrets."users/sillert".path;
    };
  };

  system.activationScripts.rhoriguchiSetup =
    let
      home = config.users.users.rhoriguchi.home;
      syncDir = config.services.custom-syncthing.syncDir;

      downloadDirs = map (path: "'${home}/Downloads/${path}'") [
        "Browser"
        "Torrent"
      ];

      createSymlink = source: target: ''
        if [ -d "${source}" ]; then
          if [ -L "${target}" ]; then
            if [ "$(readlink "${target}")" != "${source}" ]; then
              ln -sfT "${source}" "${target}"
            fi
          elif [ ! -e "${target}" ]; then
            ln -sfT "${source}" "${target}"
          fi
        fi
      '';
    in
    ''
      mkdir -p ${lib.concatStringsSep " " downloadDirs}
      chown -R rhoriguchi:${config.users.users.rhoriguchi.group} ${lib.concatStringsSep " " downloadDirs}

      ${createSymlink "${syncDir}/Git" "${home}/Git"}
      ${createSymlink "${syncDir}/Storage/KeePass" "${home}/Documents/KeePass"}
      ${createSymlink "${syncDir}/Storage/Recipes" "${home}/Documents/Recipes"}
    '';
}
