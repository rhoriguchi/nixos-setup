{ pkgs, ... }:
let
  gnomeExtensions = with pkgs.gnomeExtensions;
    [
      # caffeine
      dash-to-dock
      # desktop-icons
      # unite-shell
    ];
in {
  users.users.rhoriguchi.packages = gnomeExtensions
    ++ (with pkgs; [ papirus-icon-theme ]);

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
      "org/gnome/shell/enabled-extensions".enabled-extensions =
        map (builtins.getAttr "uuid") gnomeExtensions;
    };
  };

  # TODO sort overview alphabetically and lock it
}
