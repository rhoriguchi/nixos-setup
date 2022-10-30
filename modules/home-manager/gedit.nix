{ pkgs, ... }: {
  fonts.fontconfig.enable = true;
  home.packages = [ (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; }) ];

  dconf = {
    enable = true;

    settings."org/gnome/gedit/preferences/editor" = {
      auto-save = true;
      auto-save-interval = 1;
      display-line-numbers = true;
      editor-font = "JetBrainsMono Nerd Font";
      insert-spaces = true;
      tabs-size = 4;
      use-default-font = false;
    };
  };
}
