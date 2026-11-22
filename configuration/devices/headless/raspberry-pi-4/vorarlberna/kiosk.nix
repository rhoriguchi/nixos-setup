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

      jellyfin-desktop = prev.jellyfin-desktop.overrideAttrs (oldAttrs: {
        postPatch = (oldAttrs.postPatch or "") + ''
          sed -i '/"value": "activatesource",/{n;s/"default": true/"default": false/}' \
            resources/settings/settings_description.json

          sed -i '/Q_EMIT setProperty("vo", "libmpv");/a\    Q_EMIT setProperty("profile", "fast");' \
            src/player/MpvVideoItem.cpp
        '';
      });
    })
  ];

  systemd.services = {
    "getty@tty1".enable = false;
    "autovt@tty1".enable = false;

    cage-tty1 = {
      restartIfChanged = lib.mkForce true;

      serviceConfig = {
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };
  };

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

    program = pkgs.writeShellScript "kiosk" ''
      apply_mode() {
        output=$(${pkgs.wlr-randr}/bin/wlr-randr)

        grep -q "1920x1080 px, 60.* (current)" <<< "$output" \
          || ${pkgs.wlr-randr}/bin/wlr-randr --output HDMI-A-1 --mode 1920x1080@60Hz
      }

      apply_mode || echo "Failed to set 1080p mode, continuing at the preferred mode" >&2

      while sleep 5; do
        apply_mode || true
      done &

      exec ${pkgs.jellyfin-desktop}/bin/jellyfin-desktop ${
        lib.concatStringsSep " " [
          "--platform wayland"
          "--tv"
        ]
      }
    '';
  };
}
