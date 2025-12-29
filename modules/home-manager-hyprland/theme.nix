{
  colors,
  lib,
  pkgs,
  ...
}:
{
  home = {
    packages = [ pkgs.adwaita-fonts ];

    pointerCursor = {
      gtk.enable = true;

      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 16;
    };
  };

  gtk = {
    enable = true;

    colorScheme = "light";

    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus";
    };

    font = {
      name = "Adwaita Sans";
      size = 11;
    };
  };

  wayland.windowManager.hyprland.settings = {
    workspace = [
      # Smart gaps
      "f[1], gapsin:0, gapsout:0"
      "w[tv1], gapsin:0, gapsout:0"
    ];

    windowrule = [
      # Smart gaps
      "border_size 0, match:float false, match:workspace f[1]"
      "rounding 0, match:float false, match:workspace f[1]"
      "border_size 0, match:float false, match:workspace w[tv1]"
      "rounding 0, match:float false, match:workspace w[tv1]"
    ];

    general = {
      layout = "dwindle";

      # TODO HYPRLAND only add spacing on none screen sides https://github.com/hyprwm/Hyprland/issues/2324
      gaps_in = 5;
      gaps_out = 5;
      border_size = 3;

      "col.active_border" = "rgb(${lib.removePrefix "#" colors.normal.accent})";
      "col.inactive_border" = "rgb(${lib.removePrefix "#" colors.normal.gray})";
    };

    decoration = {
      rounding = 8;

      blur.size = 3;
    };
  };
}
