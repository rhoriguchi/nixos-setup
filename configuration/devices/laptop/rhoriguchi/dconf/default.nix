{ pkgs, ... }:
let
  extensions = with pkgs.gnomeExtensions;
    [
      # TODO commented
      # appindicator
      # caffeine
      dash-to-dock
    ];
in {
  users.users.rhoriguchi.packages = extensions
    ++ (with pkgs; [ papirus-icon-theme ]);

  home-manager.users.rhoriguchi.dconf = {
    enable = true;

    settings = {
      "ca/desrt/dconf-editor/Settings".show-warning = false;
      "org/gnome/desktop/background".picture-uri = "file:${./wallpaper.jpg}";
      "org/gnome/desktop/interface" = {
        clock-show-seconds = true;
        clock-show-weekday = true;
        icon-theme = "Papirus";
        show-battery-percentage = true;
      };
      "org/gnome/desktop/search-providers" = {
        disabled = [ "org.gnome.Contacts.desktop" ];
        sort-order =
          [ "org.gnome.Documents.desktop" "org.gnome.Nautilus.desktop" ];
      };
      "org/gnome/desktop/wm/preferences".num-workspaces = 1;
      "org/gnome/gedit/preferences/editor" = {
        display-line-numbers = true;
        insert-spaces = true;
        tabs-size = 4;
      };
      "org/gnome/login-screen" = {
        enable-fingerprint-authentication = false;
        enable-smartcard-authentication = false;
      };
      "org/gnome/mutter".dynamic-workspaces = false;
      # TODO does not work
      "org/gnome/nautilus/preferences".show-hidden-files = true;
      "org/gnome/shell" = {
        app-picker-layout = [ ];
        enabled-extensions = map (builtins.getAttr "uuid") extensions;
        favorite-apps = [ ];
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
        background-opacity = 0.0;
        bolt-support = true;
        click-action = "minimize-or-previews";
        custom-background-color = true;
        custom-theme-customize-running-dots = true;
        custom-theme-running-dots-border-color = "#FFFFFF";
        custom-theme-running-dots-border-width = 0;
        custom-theme-running-dots-color = "#D2D2D2";
        custom-theme-shrink = true;
        customize-alphas = false;
        dash-max-icon-size = 48;
        dock-fixed = true;
        dock-position = "BOTTOM";
        extend-height = false;
        force-straight-corner = true;
        height-fraction = 1.0;
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
        preferred-monitor = 1;
        pressure-threshold = 100.0;
        require-pressure-to-show = false;
        running-indicator-style = "DASHES";
        scroll-action = "do-nothing";
        scroll-switch-workspace = false;
        shift-click-action = "minimize";
        shift-middle-click-action = "skip";
        shortcut = [ ];
        shortcut-text = [ ];
        shortcut-time = 2.0;
        show-apps-at-top = true;
        show-delay = 0.25;
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

  # TODO find out what is really needed
  #   settings = {
  # keybindings
  #     "org/freedesktop/ibus/general/hotkey" = {
  #       next-engine = [ ];
  #       next-engine-in-menu = [ ];
  #       trigger = [ ];
  #       triggers = [ ];
  #     };
  #     "org/freedesktop/ibus/panel/emoji" = {
  #       hotkey = [ ];
  #       unicode-hotkey = [ ];
  #     };
  #     "org/gnome/desktop/wm/keybindings" = {
  #       activate-window-menu = [ ];
  #       begin-move = [ ];
  #       begin-resize = [ ];
  #       close = [ "<Alt>F4" ];
  #       cycle-group = [ ];
  #       cycle-group-backward = [ ];
  #       cycle-panels = [ ];
  #       cycle-panels-backward = [ ];
  #       cycle-windows = [ ];
  #       cycle-windows-backward = [ ];
  #       minimize = [ ];
  #       move-to-monitor-down = [ ];
  #       move-to-monitor-left = [ ];
  #       move-to-monitor-right = [ ];
  #       move-to-monitor-up = [ ];
  #       move-to-workspace-1 = [ ];
  #       move-to-workspace-down = [ ];
  #       move-to-workspace-last = [ ];
  #       move-to-workspace-left = [ ];
  #       move-to-workspace-right = [ ];
  #       move-to-workspace-up = [ ];
  #       panel-main-menu = [ ];
  #       show-desktop = [ "<Super>d" ];
  #       switch-applications-backward = [ ];
  #       switch-group = [ ];
  #       switch-group-backward = [ ];
  #       switch-input-source = [ ];
  #       switch-input-source-backward = [ ];
  #       switch-panels = [ ];
  #       switch-panels-backward = [ ];
  #       switch-to-workspace-1 = [ ];
  #       switch-to-workspace-down = [ ];
  #       switch-to-workspace-last = [ ];
  #       switch-to-workspace-up = [ ];
  #       switch-windows-backward = [ ];
  #       toggle-maximized = [ "<Super>Up" ];
  #       unmaximize = [ ];
  #     };
  #     "org/gnome/settings-daemon/plugins/media-keys" = {
  #       area-screenshot = [ ];
  #       area-screenshot-clip = [ ];
  #       calculator-static = [ ];
  #       email = [ ];
  #       email-static = [ ];
  #       help = [ ];
  #       home = [ ];
  #       logout = [ ];
  #       magnifier = [ ];
  #       magnifier-zoom-in = [ ];
  #       magnifier-zoom-out = [ ];
  #       screencast = [ "<Ctrl><Shift><Alt>R" ];
  #       screenreader = [ ];
  #       screenshot = [ ];
  #       screenshot-clip = [ ];
  #       terminal = [ "<Alt>t" ];
  #       window-screenshot = [ ];
  #       window-screenshot-clip = [ ];
  #       www = [ ];
  #       www-static = [ ];
  #     };
  #     "org/gnome/shell/keybindings" = {
  #       focus-active-notification = [ ];
  #       switch-to-application-1 = [ ];
  #       switch-to-application-2 = [ ];
  #       switch-to-application-3 = [ ];
  #       switch-to-application-4 = [ ];
  #       switch-to-application-5 = [ ];
  #       switch-to-application-6 = [ ];
  #       switch-to-application-7 = [ ];
  #       switch-to-application-8 = [ ];
  #       switch-to-application-9 = [ ];
  #       toggle-application-view = [ ];
  #       toggle-message-tray = [ ];
  #       toggle-overview = [ ];
  #     };
  #   };
}
