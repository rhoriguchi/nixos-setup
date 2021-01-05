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
      # TODO schema missing
      "org/gnome/shell/extensions/dash-to-dock" = {
        app-ctrl-hotkey-1 = [ ];
        app-ctrl-hotkey-10 = [ ];
        app-ctrl-hotkey-2 = [ ];
        app-ctrl-hotkey-3 = [ ];
        app-ctrl-hotkey-4 = [ ];
        app-ctrl-hotkey-5 = [ ];
        app-ctrl-hotkey-6 = [ ];
        app-ctrl-hotkey-7 = [ ];
        app-ctrl-hotkey-8 = [ ];
        app-ctrl-hotkey-9 = [ ];
        app-hotkey-1 = [ ];
        app-hotkey-10 = [ ];
        app-hotkey-2 = [ ];
        app-hotkey-3 = [ ];
        app-hotkey-4 = [ ];
        app-hotkey-5 = [ ];
        app-hotkey-6 = [ ];
        app-hotkey-7 = [ ];
        app-hotkey-8 = [ ];
        app-hotkey-9 = [ ];
        app-shift-hotkey-1 = [ ];
        app-shift-hotkey-10 = [ ];
        app-shift-hotkey-2 = [ ];
        app-shift-hotkey-3 = [ ];
        app-shift-hotkey-4 = [ ];
        app-shift-hotkey-5 = [ ];
        app-shift-hotkey-6 = [ ];
        app-shift-hotkey-7 = [ ];
        app-shift-hotkey-8 = [ ];
        app-shift-hotkey-9 = [ ];
        background-opacity = "0.0";
        click-action = "minimize-or-previews";
        custom-theme-customize-running-dots = true;
        custom-theme-running-dots-color = "#D2D2D2";
        dock-position = "BOTTOM";
        extend-height = false;
        hotkeys-overlay = false;
        hotkeys-show-dock = false;
        multi-monitor = true;
        running-indicator-style = "DASHES";
        shortcut = [ ];
        shortcut-text = [ ];
        show-apps-at-top = true;
        show-favorites = false;
        show-mounts = false;
      };
    };
  };

  # TODO sort overview alphabetically and lock it
}
