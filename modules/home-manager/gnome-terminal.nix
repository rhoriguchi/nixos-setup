{ pkgs, lib, colors, ... }: {
  fonts.fontconfig.enable = true;
  home.packages = [ (pkgs.nerdfonts.override { fonts = [ "RobotoMono" ]; }) ];

  programs.gnome-terminal = {
    enable = lib.mkDefault false;

    showMenubar = true;
    themeVariant = "system";

    profile = {
      "e17653c5-1b1f-418d-9833-ccb64992112d" = {
        default = true;

        allowBold = true;
        audibleBell = false;
        cursorBlinkMode = "on";
        customCommand = "${pkgs.zsh}/bin/zsh";
        font = "RobotoMono Nerd Font";
        visibleName = "DEFAULT";

        colors = {
          backgroundColor = "#303030";

          cursor = {
            background = colors.normal.${colors.accent};
            foreground = colors.normal.white;
          };

          highlight = {
            background = colors.normal.white;
            foreground = colors.normal.${colors.accent};
          };

          foregroundColor = colors.normal.white;

          palette = [
            colors.normal.black
            colors.normal.red
            colors.normal.green
            colors.normal.yellow
            colors.normal.blue
            colors.normal.magenta
            colors.normal.cyan
            colors.normal.gray

            colors.bright.black
            colors.bright.red
            colors.bright.green
            colors.bright.yellow
            colors.bright.blue
            colors.bright.magenta
            colors.bright.cyan
            colors.bright.gray
          ];
        };
      };
    };
  };
}
