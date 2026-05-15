{
  colors,
  config,
  lib,
  libCustom,
  osConfig,
  pkgs,
  ...
}:
let
  disabledColor = colors.extra.terminal.border;

  playAudioVolumeChange = "${osConfig.services.pipewire.package}/bin/pw-play ${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo/audio-volume-change.oga";

  swayosd-client = "${config.services.swayosd.package}/bin/swayosd-client";
in
{
  imports = [ ./submaps.nix ];

  services.swayosd = {
    enable = true;

    stylePath = pkgs.writeText "style.css" ''
      * {
        color: ${colors.normal.white};
        font-family: ${config.gtk.font.name};
      }

      window {
        background-color: ${colors.extra.terminal.background};
        border: ${toString config.wayland.windowManager.hyprland.settings.config.general.border_size}px solid ${colors.normal.accent};
        border-radius: ${toString config.wayland.windowManager.hyprland.settings.config.decoration.rounding}px;
      }

      image:disabled {
        color: ${disabledColor};
      }

      progressbar {
        min-height: 6px;
        border-radius: 999px;
        background: transparent;
        border: none;
      }

      progressbar:disabled {
        color: ${disabledColor};
      }

      progress {
        min-height: inherit;
        border-radius: inherit;
        border: none;
        background: ${colors.normal.white};
      }
    '';
  };

  wayland.windowManager.hyprland.settings.bind = [
    (libCustom.hyprland.mkExecBindRule {
      mods = "CAPS";
      key = "Caps_Lock";
      command = "${swayosd-client} --caps-lock";
      flags = {
        release = true;
        locked = true;
      };
    })
    (libCustom.hyprland.mkExecBindRule {
      key = "Scroll_Lock";
      command = "${swayosd-client} --scroll-lock";
      flags = {
        release = true;
        locked = true;
      };
    })
    (libCustom.hyprland.mkExecBindRule {
      key = "Num_Lock";
      command = "${swayosd-client} --num-lock";
      flags = {
        release = true;
        locked = true;
      };
    })

    (libCustom.hyprland.mkExecBindRule {
      key = "XF86MonBrightnessUp";
      command = "${swayosd-client} --brightness +10";
      flags = {
        locked = true;
        repeating = true;
      };
    })
    (libCustom.hyprland.mkExecBindRule {
      key = "XF86MonBrightnessDown";
      command = "${swayosd-client} --brightness -10";
      flags = {
        locked = true;
        repeating = true;
      };
    })

    (libCustom.hyprland.mkExecBindRule {
      key = "XF86AudioPlay";
      command = "${swayosd-client} --playerctl play-pause";
      flags.locked = true;
    })
    (libCustom.hyprland.mkExecBindRule {
      key = "XF86AudioNext";
      command = "${swayosd-client} --playerctl next";
      flags.locked = true;
    })
    (libCustom.hyprland.mkExecBindRule {
      key = "XF86AudioPrev";
      command = "${swayosd-client} --playerctl prev";
      flags.locked = true;
    })

    (libCustom.hyprland.mkExecBindRule {
      key = "XF86AudioRaiseVolume";
      command = lib.concatStringsSep " && " [
        "${swayosd-client} --output-volume +5"
        playAudioVolumeChange
      ];
      flags = {
        locked = true;
        repeating = true;
      };
    })
    (libCustom.hyprland.mkExecBindRule {
      key = "XF86AudioLowerVolume";
      command = lib.concatStringsSep " && " [
        "${swayosd-client} --output-volume -5"
        playAudioVolumeChange
      ];
      flags = {
        locked = true;
        repeating = true;
      };
    })
    (libCustom.hyprland.mkExecBindRule {
      key = "XF86AudioMute";
      command = lib.concatStringsSep " && " [
        "${swayosd-client} --output-volume mute-toggle"
        playAudioVolumeChange
      ];
      flags.locked = true;
    })
    (libCustom.hyprland.mkExecBindRule {
      key = "XF86AudioMicMute";
      command = "${swayosd-client} --input-volume mute-toggle";
      flags.locked = true;
    })
  ];
}
