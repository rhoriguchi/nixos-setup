{ pkgs, ... }: {
  # TODO commented
  # users.users.rhoriguchi.packages = (with pkgs; [ papirus-icon-theme ])
  #  ++ (with pkgs.gnomeExtensions; [
  #    caffeine
  #    dash-to-dock
  #    desktop-icons
  #    unite-shell
  #  ]);

  home-manager.users.rhoriguchi.dconf = {
    enable = true;

    settings = {
      "org/gnome/desktop/background".picture-uri = "file:${./wallpaper.jpg}";
      "org/gnome/desktop/interface" = {
        clock-show-seconds = true;
        clock-show-weekday = true;
        icon-theme = "Papirus";
        show-battery-percentage = true;
      };
    };
  };
}
