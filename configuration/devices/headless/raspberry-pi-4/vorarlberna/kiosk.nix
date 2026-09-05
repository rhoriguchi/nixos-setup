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

  systemd.services.cage-tty1 = {
    restartIfChanged = lib.mkForce true;

    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "5s";
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

      "-D" # Enable debug logging
    ];

    environment = {
      WLR_LIBINPUT_NO_DEVICES = "1";

      XKB_DEFAULT_LAYOUT = config.services.xserver.xkb.layout;
      XKB_DEFAULT_MODEL = config.services.xserver.xkb.model;
      XKB_DEFAULT_VARIANT = config.services.xserver.xkb.variant;

      WLR_LOG = "debug";

      # The vc4/v3d GPU-accelerated path (direct KMS scanout of tiled
      # client buffers at the TV's 4K preferred mode) exhausts the
      # kernel's swiotlb DMA bounce-buffer pool within ~30s, aborting
      # QtWebEngine (qFatal in NativeSkiaOutputDeviceOpenGL::texture()).
      # Bigger swiotlb/cma pools and forcing a lower mode did not help.
      # The wlroots software (pixman) renderer sidesteps GPU/DMA-buf
      # scanout entirely and has run crash-free where GLES2 crashed
      # every ~30s.
      WLR_RENDERER = "pixman";

      # With only the compositor forced to software, jellyfin-desktop's
      # QtWebEngine/Chromium still rendered its own frames on the GPU,
      # so every frame paid for a GPU render + CPU readback + CPU
      # composite. Disabling GPU rendering client-side too avoids that
      # round-trip and keeps the whole pipeline on one consistent path.
      QT_QUICK_BACKEND = "software";
      QTWEBENGINE_CHROMIUM_FLAGS = "--disable-gpu";
    };

    program = "${pkgs.jellyfin-desktop}/bin/jellyfin-desktop ${
      lib.concatStringsSep " " [
        "--platform wayland"
        "--tv"
      ]
    }";
  };
}
