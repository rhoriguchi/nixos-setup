{ pkgs, ... }:
# TODO hand this over as variable
let username = "rhoriguchi";
in {
  users.users."${username}".packages = (with pkgs; [ papirus-icon-theme ])
    ++ (with pkgs.gnomeExtensions; [ dash-to-dock desktop-icons ]);

  home-manager.users."${username}".dconf = {
    enable = true;

    settings = {
      "org/gnome/desktop/background" = {
        picture-uri = "file:${./wallpaper.jpg}";
      };
      "org/gnome/desktop/interface" = {
        clock-show-seconds = true;
        clock-show-weekday = true;
        icon-theme = "Papirus";
        show-battery-percentage = true;
      };
    };
  };
}
