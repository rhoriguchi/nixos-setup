{
  config,
  lib,
  ...
}:
{
  imports = [
    ./hp-g4.nix
    ./keepassxc.nix
    ./rsnapshot.nix
    ./wifi.nix

    ./hardware-configuration.nix
  ];

  sops = {
    secrets = {
      "nix/settings/access-tokens/github.com" = { };

      "users/rhoriguchi".neededForUsers = true;
      "users/sillert".neededForUsers = true;
    };

    templates = {
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

  networking.hostName = "XXLPitu-Aizen";

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
