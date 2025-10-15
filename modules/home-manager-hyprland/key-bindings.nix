{
  colors,
  config,
  lib,
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
  services.swayosd = {
    enable = true;

    stylePath = pkgs.writeText "style.css" ''
      * {
        color: ${colors.normal.white};
        font-family: ${config.gtk.font.name};
      }

      window {
        background-color: ${colors.extra.terminal.background};
        border: ${toString config.wayland.windowManager.hyprland.settings.general.border_size}px solid ${colors.normal.accent};
        border-radius: ${toString config.wayland.windowManager.hyprland.settings.decoration.rounding}px;
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

  wayland.windowManager.hyprland = {
    settings = {
      "$mainMod" = "SUPER";
      "$terminal" = "${config.programs.ghostty.package}/bin/ghostty";

      bind = [
        "$mainMod, Q, exec, $terminal"
        "$mainMod, C, killactive,"
        "$mainMod, V, togglefloating,"
        "$mainMod, F, fullscreen,"
        "$mainMod, P, pseudo,"

        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"

        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"

        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"

        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"

        "$mainMod, M, submap, move"
        "$mainMod, N, submap, resize"
      ];

      # e	repeat	Will repeat when held.
      # l	locked	Will also work when an input inhibitor (e.g. a lockscreen) is active.
      bindel = [
        ", XF86AudioRaiseVolume, exec, ${
          lib.concatStringsSep " && " [
            "${swayosd-client} --output-volume +5"
            playAudioVolumeChange
          ]
        }"
        ", XF86AudioLowerVolume, exec, ${
          lib.concatStringsSep " && " [
            "${swayosd-client} --output-volume -5"
            playAudioVolumeChange
          ]
        }"

        ", XF86MonBrightnessUp, exec, ${swayosd-client} --brightness +10"
        ", XF86MonBrightnessDown, exec, ${swayosd-client} --brightness -10"
      ];

      # l	locked	Will also work when an input inhibitor (e.g. a lockscreen) is active.
      bindl = [
        ", XF86AudioPlay, exec, ${swayosd-client} --playerctl play-pause"
        ", XF86AudioNext, exec, ${swayosd-client} --playerctl next"
        ", XF86AudioPrev, exec, ${swayosd-client} --playerctl prev"

        ", XF86AudioMute, exec, ${
          lib.concatStringsSep " && " [
            "${swayosd-client} --output-volume mute-toggle"
            playAudioVolumeChange
          ]
        }"
        ", XF86AudioMicMute, exec, ${swayosd-client} --input-volume mute-toggle"
      ];

      # l	locked	Will also work when an input inhibitor (e.g. a lockscreen) is active.
      # r	release	Will trigger on release of a key.
      bindlr = [
        "CAPS, Caps_Lock, exec, ${swayosd-client} --caps-lock"
        ", Scroll_Lock, exec, ${swayosd-client} --scroll-lock"
        ", Num_Lock, exec, ${swayosd-client} --num-lock"
      ];

      # m	mouse	See the dedicated Mouse Binds section.
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      gesture = [
        "3, horizontal, workspace"
        "3, swipe, mod: $mainMod, resize"
      ];
    };

    submaps = {
      move.settings = {
        bind = [ ", escape, submap, reset" ];

        # e	repeat	Will repeat when held.
        binde = [
          ", left, moveactive, -10 0"
          ", right, moveactive, 10 0"
          ", up, moveactive, 0 -10"
          ", down, moveactive, 0 10"
        ];
      };

      resize.settings = {
        bind = [ ", escape, submap, reset" ];

        # e	repeat	Will repeat when held.
        binde = [
          ", left, resizeactive, -10 0"
          ", right, resizeactive, 10 0"
          ", up, resizeactive, 0 -10"
          ", down, resizeactive, 0 10"
        ];
      };
    };
  };
}
