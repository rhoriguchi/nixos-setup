{ pkgs, lib, colors, ... }: {
  gtk = {
    enable = true;

    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus";
    };

    # TODO test
    theme = {
      package = pkgs.yaru-theme;
      name = "Yaru-blue";
    };

    # TODO test
    cursorTheme = {
      package = pkgs.yaru-theme;
      name = "Yaru-blue";
    };
  };

  wayland.windowManager.hyprland.extraConfig = ''
    # See https://wiki.hyprland.org/Configuring/Monitors/
    monitor=,preferred,auto,auto

    general {
      # See https://wiki.hyprland.org/Configuring/Variables/ for more

      gaps_in = 5
      gaps_out = 5
      border_size = 2
      col.active_border = rgb(${lib.removePrefix "#" colors.normal.accent})
      col.inactive_border = rgb(${lib.removePrefix "#" colors.normal.gray})

      layout = dwindle
    }

    decoration {
      # See https://wiki.hyprland.org/Configuring/Variables/ for more

      rounding = 8
      blur = yes
      blur_size = 3
      blur_passes = 1
      blur_new_optimizations = on

      drop_shadow = yes
      shadow_range = 4
      shadow_render_power = 3
      col.shadow = rgba(1a1a1aee)
    }

    animations {
      enabled = yes

      # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

      bezier = myBezier, 0.05, 0.9, 0.1, 1.05

      animation = windows, 1, 7, myBezier
      animation = windowsOut, 1, 7, default, popin 80%
      animation = border, 1, 10, default
      animation = borderangle, 1, 8, default
      animation = fade, 1, 7, default
      animation = workspaces, 1, 6, default
    }
  '';
}
