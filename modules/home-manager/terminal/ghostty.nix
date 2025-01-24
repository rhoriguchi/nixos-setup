{ colors, pkgs, ... }: {
  home.packages = [ pkgs.nerd-fonts.roboto-mono ];

  programs.ghostty = {
    enable = true;

    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;

    clearDefaultKeybinds = true;

    settings = {
      confirm-close-surface = false;
      window-save-state = "never";

      title = ''" "'';
      theme = "Custom";
      selection-invert-fg-bg = true;

      font-size = 10;
      font-style = "RobotoMono Nerd Font";
      font-style-bold = "RobotoMono Nerd Font Bd";
      font-style-italic = "RobotoMono Nerd Font It";
      font-style-bold-italic = "RobotoMono Nerd Font Bd It";
      font-feature = [ "-calt" "-dlig" "-liga" ];

      adjust-cursor-thickness = "150%";

      mouse-hide-while-typing = true;
      mouse-scroll-multiplier = 0.3;

      clipboard-read = "allow";
      clipboard-write = "allow";
      clipboard-trim-trailing-spaces = true;
      clipboard-paste-protection = false;
      copy-on-select = false;

      link-url = true;

      keybind = [
        "ctrl+shift+c=copy_to_clipboard"
        "ctrl+shift+v=paste_from_clipboard"

        "ctrl+plus=increase_font_size:1"
        "ctrl+minus=decrease_font_size:1"
        "ctrl+zero=reset_font_size"
      ];
    };

    themes.Custom = {
      background = colors.extra.terminal.background;
      foreground = colors.normal.white;

      cursor-color = colors.normal.accent;
      cursor-text = colors.normal.white;

      palette = [
        "0=${colors.normal.black}"
        "1=${colors.normal.red}"
        "2=${colors.normal.green}"
        "3=${colors.normal.yellow}"
        "4=${colors.normal.blue}"
        "5=${colors.normal.magenta}"
        "6=${colors.normal.cyan}"
        "7=${colors.normal.white}"

        "8=${colors.bright.black}"
        "9=${colors.bright.red}"
        "10=${colors.bright.green}"
        "11=${colors.bright.yellow}"
        "12=${colors.bright.blue}"
        "13=${colors.bright.magenta}"
        "14=${colors.bright.cyan}"
        "15=${colors.bright.white}"
      ];
    };
  };
}
