{ colors, config, lib, ... }: {
  programs.hyprlock = {
    enable = true;

    settings = {
      background = {
        path = "${./background/wallpaper.jpg}";

        blur_size = 4;
        blur_passes = 3;
        contrast = 1.3;
        vibrancy_darkness = 0.0;
      };

      label = [
        # Time
        {
          text = "$TIME";
          color = "rgb(${lib.removePrefix "#" colors.normal.white})";
          font_size = 100;
          font_family = config.gtk.font.name;

          position = "0, 95";
        }

        # Date
        {
          text = ''cmd[] echo "$(date +"%A, %B %d")"'';
          color = "rgb(${lib.removePrefix "#" colors.normal.white})";
          font_size = 20;
          font_family = config.gtk.font.name;

          position = "0, 0";
        }
      ];

      # TODO HYPRLAND show capslock symbol if active https://unix.stackexchange.com/questions/796275/how-to-show-the-capslock-status-in-hyprlock-lockscreen-in-hyprland
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

  wayland.windowManager.hyprland.settings.bind = [ "$mainMod, L, exec, ${config.programs.hyprlock.package}/bin/hyprlock" ];
}
