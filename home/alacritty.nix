{ pkgs, utils, config, colors, ... }: {
  fonts.fontconfig.enable = true;
  home.packages = [ pkgs.nerdfonts ];

  programs.alacritty = {
    enable = true;

    settings = {
      shell.program = "/run/current-system/sw${pkgs.zsh.shellPath}";
      working_directory = config.home.homeDirectory;
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
