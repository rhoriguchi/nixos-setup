{
  config,
  lib,
  pkgs,
  ...
}:
{
  nixpkgs.overlays = [
    (_: prev: {
      libcec = prev.libcec.override { withLibraspberrypi = true; };

      # Prevent Jellyfin from automatically switching the TV to its HDMI input via HDMI-CEC.
      jellyfin-desktop = prev.jellyfin-desktop.overrideAttrs (oldAttrs: {
        postPatch = (oldAttrs.postPatch or "") + ''
          sed -i '/"value": "activatesource",/{n;s/"default": true/"default": false/}' \
            resources/settings/settings_description.json
        '';
      });
    })
  ];

  users.users.${config.services.cage.user} = {
    isNormalUser = true;

    extraGroups = [
      "video"
    ];
  };

  services.cage = {
    enable = true;

    extraArguments = [
      "-d" # Don't draw client side decorations, when possible
    ];

    environment = {
      WLR_LIBINPUT_NO_DEVICES = "1";

      XKB_DEFAULT_LAYOUT = config.services.xserver.xkb.layout;
      XKB_DEFAULT_MODEL = config.services.xserver.xkb.model;
      XKB_DEFAULT_VARIANT = config.services.xserver.xkb.variant;
    };

    program = "${pkgs.jellyfin-desktop}/bin/jellyfin-desktop ${
      lib.concatStringsSep " " [
        "--platform wayland"
        "--tv"
      ]
    }";
  };
}
