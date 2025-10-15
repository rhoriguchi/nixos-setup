{
  colors,
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
{
  programs.hyprlock = {
    enable = true;

    settings = {
      background = {
        path = "${pkgs.wallpaper}/share/icons/hicolor/3840x2160/apps/wallpaper.jpg";

        blur_size = 4;
        blur_passes = 3;
        contrast = 1.3;
        vibrancy_darkness = 0.0;
      };

      label = [
        # Time
        {
          text = "cmd[update:200] date +'%H:%M:%S'";
          color = "rgb(${lib.removePrefix "#" colors.normal.white})";
          font_size = 100;
          font_family = config.gtk.font.name;

          position = "0, 95";
        }

        # Date
        {
          text = "cmd[update:1000] date +'%A, %B %d'";
          color = "rgb(${lib.removePrefix "#" colors.normal.white})";
          font_size = 20;
          font_family = config.gtk.font.name;

          position = "0, 0";
        }
      ];

      input-field = {
        size = "250, 50";
        outline_thickness = 3;
        outer_color = "rgba(${lib.removePrefix "#" colors.extra.terminal.border}66)";
        inner_color = "rgba(${lib.removePrefix "#" colors.extra.terminal.background}66)";

        font_color = "rgb(${lib.removePrefix "#" colors.normal.white})";
        check_color = "rgb(${lib.removePrefix "#" colors.normal.green})";
        fail_color = "rgb(${lib.removePrefix "#" colors.normal.red})";
        placeholder_text = "<i>Password...</i>";
        fade_on_empty = true;

        dots_size = 0.2;
        dots_spacing = 0.64;
        dots_center = true;

        hide_input = false;

        position = "0, 150";
        valign = "bottom";
      };
    };
  };

  wayland.windowManager.hyprland.settings.bind = [
    "$mainMod, L, exec, ${osConfig.systemd.package}/bin/loginctl lock-session"
  ];
}
