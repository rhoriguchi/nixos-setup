{
  config,
  lib,
  pkgs,
  ...
}:
{
  nixpkgs.overlays = [
    (_: prev: { libcec = prev.libcec.override { withLibraspberrypi = true; }; })
  ];

  boot.kernelParams = [ "cma=256M" ];

  hardware.graphics.enable = true;

  users.users.${config.services.cage.user} = {
    isNormalUser = true;

    extraGroups = [
      "video"
    ];
  };

  services = {
    udev.extraRules = ''
      KERNEL=="vchiq", GROUP="video", MODE="0660", TAG+="systemd", ENV{SYSTEMD_ALIAS}="/dev/vchiq"
    '';

    cage = {
      enable = true;

      extraArguments = [
        "-d" # Don't draw client side decorations, when possible

        "-D" # Enable debug logging
      ];

      environment = {
        WLR_LIBINPUT_NO_DEVICES = "1";

        XKB_DEFAULT_LAYOUT = config.services.xserver.xkb.layout;
        XKB_DEFAULT_MODEL = config.services.xserver.xkb.model;
        XKB_DEFAULT_VARIANT = config.services.xserver.xkb.variant;

        WLR_LOG = "debug";
      };

      program = "${pkgs.jellyfin-desktop}/bin/jellyfin-desktop ${
        lib.concatStringsSep " " [
          "--platform wayland"
          "--tv"
        ]
      }";
    };
  };
}
