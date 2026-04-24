{
  config,
  lib,
  secrets,
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

  documentation = {
    doc.enable = false;
    nixos.enable = false;
    info.enable = false;
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

  nix.settings.access-tokens = lib.concatStringsSep " " (
    lib.mapAttrsToList (key: value: "${key}=${value}") secrets.git.accessTokens
  );

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

      networks =
        lib.recursiveUpdate
          (lib.mapAttrs (
            key: value:
            value
            // {
              extraConfig = lib.concatStringsSep "\n" (
                lib.catAttrs "extraConfig" [ value ]
                ++ [
                  (
                    if
                      (lib.elem key [
                        "63466727"
                        "63466727-Guest"
                        "63466727-IoT"
                        "Niflheim"
                      ])
                    then
                      "mac_addr=0"
                    else
                      "mac_addr=2"
                  )
                ]
              );
            }
          ) secrets.wifis)
          {
            "63466727".priority = 100;
            Niflheim.priority = 10;
          };
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
      password = secrets.users.rhoriguchi.password;
    };

    sillert = {
      extraGroups = [
        "networkmanager"
        "plugdev"
      ]
      ++ (lib.optional config.hardware.openrazer.enable "openrazer")
      ++ (lib.optional config.networking.wireless.enable "wpa_supplicant");
      isNormalUser = true;
      password = secrets.users.sillert.password;
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
        if [ -d "${source}" ] && [ ! \( -L "${target}" \) ] && [ ! \( -e "${target}" \) ]; then
          rm -rf "${target}"
          ln -sf "${source}" "${target}"
        fi
      '';
    in
    ''
      mkdir -p ${lib.concatStringsSep " " downloadDirs}
      chown -R rhoriguchi:${config.users.users.rhoriguchi.group} ${lib.concatStringsSep " " downloadDirs}

      ${createSymlink "${syncDir}/Git" "${home}/Git"}
      ${createSymlink "${syncDir}/KeePass" "${home}/Documents/KeePass"}
      ${createSymlink "${syncDir}/Storage/Recipes" "${home}/Documents/Recipes"}
    '';
}
