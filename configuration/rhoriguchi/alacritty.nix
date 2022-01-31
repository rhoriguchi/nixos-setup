{ pkgs, utils, config, ... }:
let colors = (import ../colors.nix);
in {
  fonts.fonts = [ pkgs.nerdfonts ];

  home-manager.users.rhoriguchi.programs.alacritty = {
    enable = true;

    settings = {
      shell.program = "${utils.toShellPath config.users.defaultUserShell}";
      working_directory = config.users.users.rhoriguchi.home;
      window.startup_mode = "Maximized";

      scrolling = {
        history = 10000;
        multiplier = 3;
      };

      font = {
        normal = {
          family = "RobotoMono Nerd Font";
          style = "Regular";
        };

        bold = {
          family = "RobotoMono Nerd Font";
          style = "Bold";
        };

        italic = {
          family = "RobotoMono Nerd Font";
          style = "Italic";
        };
      };

      colors = {
        primary = {
          background = "#303030";
          foreground = colors.normal.white;
        };

        cursor = {
          cursor = colors.normal.magenta;
          text = colors.normal.white;
        };

        normal = colors.normal;
        bright = colors.bright;
      };
    };
  };
}
