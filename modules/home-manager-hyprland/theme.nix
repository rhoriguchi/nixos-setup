{
  colors,
  lib,
  libCustom,
  pkgs,
  ...
}:
{
  home = {
    packages = [ pkgs.adwaita-fonts ];

    pointerCursor = {
      enable = true;

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
    workspace_rule = [
      {
        workspace = "f[1]";
        gaps_in = 0;
        gaps_out = 0;
      }
      {
        workspace = "w[tv1]";
        gaps_in = 0;
        gaps_out = 0;
      }
    ];

    window_rule =
      libCustom.hyprland.mkWindowRules
        {
          border_size = 0;
          rounding = 0;
        }
        [
          {
            float = false;
            workspace = "f[1]";
          }
          {
            float = false;
            workspace = "w[tv1]";
          }
        ];

    config = {
      general = {
        layout = "dwindle";

        gaps_in = 5;
        gaps_out = 0;
        border_size = 3;

        col = {
          active_border = "rgb(${lib.removePrefix "#" colors.normal.accent})";
          inactive_border = "rgb(${lib.removePrefix "#" colors.normal.gray})";
        };
      };

      decoration = {
        rounding = 8;

        blur.size = 3;
      };
    };
  };
}
