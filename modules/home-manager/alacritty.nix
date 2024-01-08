{ pkgs, config, colors, ... }: {
  fonts.fontconfig.enable = true;
  home.packages = [ (pkgs.nerdfonts.override { fonts = [ "RobotoMono" ]; }) ];

  home.sessionVariables.TERMINAL = "alacritty";

  programs.alacritty = {
    enable = true;

    settings = {
      shell.program = "${pkgs.zsh}/bin/zsh";
      working_directory = config.home.homeDirectory;
      window.startup_mode = "Maximized";

      scrolling = {
        history = 10 * 1000;
        multiplier = 3;
      };

      font = {
        size = 10;

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
          cursor = colors.normal.accent;
          text = colors.normal.white;
        };

        normal = removeAttrs colors.normal [ "accent" "gray" ];
        bright = removeAttrs colors.bright [ "accent" "gray" ];
      };
    };
  };
}
