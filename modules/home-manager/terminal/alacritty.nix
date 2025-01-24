{ colors, config, pkgs, ... }: {
  home.packages = [ pkgs.nerd-fonts.roboto-mono ];

  programs.alacritty = {
    enable = true;

    settings = {
      general.working_directory = config.home.homeDirectory;
      window.startup_mode = "Maximized";

      # fc-list : family style
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

        bold_italic = {
          family = "RobotoMono Nerd Font";
          style = "Bold Italic";
        };
      };

      colors = {
        primary = {
          background = colors.extra.terminal.background;
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
