{ pkgs, ... }: {
  home.packages = [ pkgs.nerd-fonts.jetbrains-mono pkgs.gnome-text-editor ];

  dconf = {
    enable = true;

    settings."org/gnome/TextEditor" = {
      custom-font = "JetBrainsMono Nerd Font";
      highlight-current-line = true;
      indent-style = "space";
      restore-session = false;
      show-line-numbers = true;
      show-map = true;
      spellcheck = false;
      style-scheme = "Adwaita";
      tab-width = 4;
      use-system-font = false;
    };
  };
}
