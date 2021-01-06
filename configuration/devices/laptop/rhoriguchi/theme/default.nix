{ pkgs, ... }:
let
  gnomeExtensions = with pkgs.gnomeExtensions;
    [
      # caffeine
      dash-to-dock
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
      "org/gnome/shell" = {
        app-picker-layout = [ ];
        enabled-extensions = map (builtins.getAttr "uuid") gnomeExtensions;
      };
      "org/gnome/shell/extensions/dash-to-dock" = {
        activate-single-window = true;
        animate-show-apps = true;
        animation-time = 0.2;
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
        apply-custom-theme = false;
        autohide = false;
        autohide-in-fullscreen = false;
        background-color = "#FFFFFF";
        background-opacity = 0;
        bolt-support = true;
        click-action = "minimize-or-previews";
        custom-background-color = true;
        custom-theme-customize-running-dots = true;
        custom-theme-running-dots-border-color = "#FFFFFF";
        custom-theme-running-dots-border-width = 0;
        custom-theme-running-dots-color = "#D2D2D2";
        customize-alphas = false;
        dash-max-icon-size = 48;
        dock-fixed = true;
        dock-position = "BOTTOM";
        extend-height = false;
        force-straight-corner = true;
        height-fraction = 1;
        hide-delay = 0.2;
        hot-keys = true;
        hotkeys-overlay = false;
        hotkeys-show-dock = false;
        icon-size-fixed = true;
        intellihide = true;
        intellihide-mode = "FOCUS_APPLICATION_WINDOWS";
        isolate-monitors = false;
        isolate-workspaces = true;
        max-alpha = 0.8;
        middle-click-action = "skip";
        min-alpha = 0.2;
        minimize-shift = true;
        multi-monitor = true;
        preferred-monitor = true;
        pressure-threshold = 100;
        require-pressure-to-show = false;
        running-indicator-style = "DASHES";
        scroll-action = "do-nothing";
        scroll-switch-workspace = false;
        shift-click-action = "minimize";
        shift-middle-click-action = "skip";
        shortcut = [ ];
        shortcut-text = [ ];
        shortcut-time = 2;
        show-apps-at-top = true;
        show-delay-tim = 0.25;
        show-favorites = false;
        show-mounts = false;
        show-running = true;
        show-show-apps-button = true;
        show-trash = false;
        show-windows-preview = true;
        transparency-mode = "FIXED";
        unity-backlit-items = false;
      };
    };
  };

  # TODO sort overview alphabetically and lock it
}
