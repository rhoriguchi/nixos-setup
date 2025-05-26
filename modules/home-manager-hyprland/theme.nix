{ colors, lib, pkgs, ... }: {
  home = {
    packages = [ pkgs.adwaita-fonts ];

    # TODO HYPRLAND use hyprcursor?
    pointerCursor = {
      gtk.enable = true;

      # TODO HYPRLAND change?
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 16;
    };
  };

  gtk = {
    enable = true;

    # TODO HYPRLAND commented, needed?
    # theme = {
    #   package = pkgs.yaru-theme;
    #   name = "Yaru-blue";
    # };

    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus";
    };

    font = {
      name = "Adwaita Sans";
      size = 11;
    };
  };

  # TODO HYPRLAND qt style? https://github.com/nix-community/home-manager/blob/master/modules/misc/qt.nix

  wayland.windowManager.hyprland.settings = {
    workspace = [
      # Smart gaps
      "f[1], gapsin:0, gapsout:0"
      "w[tv1], gapsin:0, gapsout:0"
    ];

    windowrule = [
      # Smart gaps
      "bordersize 0, floating:0, onworkspace:f[1]"
      "rounding 0, floating:0, onworkspace:f[1]"
      "bordersize 0, floating:0, onworkspace:w[tv1]"
      "rounding 0, floating:0, onworkspace:w[tv1]"
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
