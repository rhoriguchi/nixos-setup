{ pkgs, ... }: {
  fonts.fonts = [ pkgs.nerdfonts ];

  home-manager.users.rhoriguchi.dconf = {
    enable = true;

    settings."org/gnome/gedit/preferences/editor" = {
      display-line-numbers = true;
      editor-font = "JetBrainsMono Nerd Font";
      insert-spaces = true;
      tabs-size = 4;
      use-default-font = false;
    };
  };
}