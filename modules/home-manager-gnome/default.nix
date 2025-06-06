{ colors, lib, pkgs, ... }:
let
  extensions = [
    pkgs.gnomeExtensions.alphabetical-app-grid
    pkgs.gnomeExtensions.appindicator
    pkgs.gnomeExtensions.caffeine
    pkgs.gnomeExtensions.dash-to-dock
    pkgs.gnomeExtensions.date-menu-formatter
    pkgs.gnomeExtensions.launch-new-instance
    pkgs.gnomeExtensions.tophat
    pkgs.gnomeExtensions.transparent-top-bar-adjustable-transparency
    pkgs.gnomeExtensions.unite
    pkgs.gnomeExtensions.user-themes
    pkgs.gnomeExtensions.window-is-ready-remover
  ];
in {
  home.packages = extensions;

  dconf = {
    enable = true;

    settings = {
      "com/ftpix/transparentbar" = {
        dark-full-screen = true;
        transparency = 0;
      };
      "org/gnome/desktop/background" = rec {
        picture-uri = "file://${./wallpaper.jpg}";
        picture-uri-dark = picture-uri;
      };
      "org/gnome/desktop/calendar".show-weekdate = true;
      "org/gnome/desktop/datetime".automatic-timezone = true;
      # needed for US keyboard
      "org/gnome/desktop/input-sources".sources =
        [ (lib.hm.gvariant.mkTuple [ "xkb" "ch+de_nodeadkeys" ]) (lib.hm.gvariant.mkTuple [ "xkb" "us" ]) ];
      "org/gnome/desktop/interface" = {
        clock-show-seconds = true;
        clock-show-weekday = true;
        enable-hot-corners = false;
        show-battery-percentage = true;
      };
      "org/gnome/desktop/notifications".show-banners = true;
      "org/gnome/desktop/wm/keybindings" = {
        activate-window-menu = [ ];
        begin-move = [ "<Alt>F7" ];
        begin-resize = [ ];
        close = [ "<Alt>F4" ];
        cycle-group = [ ];
        cycle-group-backward = [ ];
        cycle-panels = [ ];
        cycle-panels-backward = [ ];
        cycle-windows = [ ];
        cycle-windows-backward = [ ];
        minimize = [ ];
        move-to-monitor-down = [ ];
        move-to-monitor-left = [ ];
        move-to-monitor-right = [ ];
        move-to-monitor-up = [ ];
        move-to-workspace-1 = [ ];
        move-to-workspace-down = [ ];
        move-to-workspace-last = [ ];
        move-to-workspace-left = [ ];
        move-to-workspace-right = [ ];
        move-to-workspace-up = [ ];
        panel-main-menu = [ ];
        show-desktop = [ "<Super>d" ];
        switch-applications = [ "<ALT>Tab" ];
        switch-applications-backward = [ ];
        switch-group = [ ];
        switch-group-backward = [ ];
        switch-input-source = [ ];
        switch-input-source-backward = [ ];
        switch-panels = [ ];
        switch-panels-backward = [ ];
        switch-to-workspace-1 = [ ];
        switch-to-workspace-down = [ ];
        switch-to-workspace-last = [ ];
        switch-to-workspace-up = [ ];
        toggle-maximized = [ "<Super>Up" ];
        unmaximize = [ "<Super>Down>" ];
      };
      "org/gnome/desktop/wm/preferences" = {
        button-layout = ":minimize,maximize,close";
        num-workspaces = 1;
      };
      "org/gnome/mutter".dynamic-workspaces = false;
      "org/gnome/mutter/keybindings" = {
        toggle-tiled-left = [ "<Super>Left" ];
        toggle-tiled-right = [ "<Super>Right" ];
      };
      "org/gnome/settings-daemon/plugins/color" = {
        night-light-enabled = true;
        night-light-schedule-automatic = true;
        night-light-temperature = lib.hm.gvariant.mkUint32 3300;
      };
      "org/gnome/settings-daemon/plugins/media-keys" = {
        area-screenshot = [ ];
        area-screenshot-clip = [ ];
        help = [ ];
        magnifier = [ ];
        magnifier-zoom-in = [ ];
        magnifier-zoom-out = [ ];
        screencast = [ ];
        screenreader = [ ];
        screenshot = [ ];
        screenshot-clip = [ ];
        window-screenshot = [ ];
        window-screenshot-clip = [ ];
      };
      "org/gnome/shell" = {
        app-picker-layout = [ ];
        enabled-extensions =
          map (extension: if lib.hasAttr "extensionUuid" extension then extension.extensionUuid else extension.uuid) extensions;
        favorite-apps = [ ];
        welcome-dialog-last-shown-version = "9999999999";
      };
      "org/gnome/shell/extensions/alphabetical-app-grid" = {
        folder-order-position = "alphabetical";
        logging-enabled = false;
        show-favourite-apps = false;
        sort-folder-contents = true;
      };
      "org/gnome/shell/extensions/caffeine" = {
        enable-fullscreen = false;
        indicator-position = 0;
        indicator-position-index = 0;
        indicator-position-max = 1;
        inhibit-apps = [ ];
        nightlight-control = "never";
        prefs-default-height = 600;
        prefs-default-width = 700;
        restore-state = false;
        screen-blank = "never";
        show-indicator = "only-active";
        show-notifications = false;
        show-timer = true;
        toggle-shortcut = [ ];
        trigger-apps-mode = "on-running";
        user-enabled = false;
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
        background-color = colors.normal.white;
        background-opacity = 0.0;
        bolt-support = true;
        click-action = "minimize-or-previews";
        custom-background-color = true;
        custom-theme-customize-running-dots = true;
        custom-theme-running-dots-border-color = colors.normal.white;
        custom-theme-running-dots-border-width = 0;
        custom-theme-running-dots-color = colors.normal.gray;
        custom-theme-shrink = true;
        customize-alphas = false;
        dash-max-icon-size = 48;
        dock-fixed = true;
        dock-position = "BOTTOM";
        extend-height = false;
        force-straight-corner = true;
        height-fraction = 1.0;
        hide-delay = 0.2;
        hot-keys = false;
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
      "org/gnome/shell/extensions/date-menu-formatter" = {
        apply-all-panels = true;
        custom-locale = "";
        font-size = 12;
        pattern = "dd.MM.yyyy HH:mm:ss";
        remove-messages-indicator = false;
        use-default-locale = true;
      };
      "org/gnome/shell/extensions/dynamic-panel-transparency" = {
        enable-background-color = false;
        enable-maximized-text-color = false;
        enable-opacity = true;
        enable-overview-text-color = false;
        enable-text-color = false;
        force-animation = false;
        hide-corners = true;
        icon-shadow = false;
        icon-shadow-color = "(0,0,0,0.5)";
        icon-shadow-position = "(0,2,5)";
        maximized-opacity = 255;
        maximized-text-color = "(255,255,255)";
        panel-color = [ 0 0 0 ];
        remove-panel-styling = true;
        text-color = "(255,255,255)";
        text-shadow = false;
        text-shadow-color = "(0,0,0,1.0)";
        text-shadow-position = "(0,3,5)";
        transition-speed = 1000;
        transition-type = 1;
        transition-windows-touch = false;
        transition-with-overview = true;
        unmaximized-opacity = 0;
      };
      "org/gnome/shell/extensions/gnome-fuzzy-app-search".applications = true;
      "org/gnome/shell/extensions/tophat" = {
        cpu-show-cores = true;
        meter-bar-width = 0.6;
        meter-fg-color = colors.normal.white;
        mount-to-monitor = "";
        network-usage-unit = "bytes";
        position-in-panel = "right";
        show-animations = true;
        show-cpu = true;
        show-disk = false;
        show-icons = true;
        show-mem = true;
        show-net = true;
      };
      "org/gnome/shell/extensions/unite" = {
        app-menu-ellipsize-mode = "end";
        app-menu-max-width = 0;
        autofocus-windows = true;
        desktop-name-text = "";
        ellipsizeMode = "end";
        enable-titlebar-actions = true;
        extend-left-box = false;
        greyscale-tray-icons = false;
        hide-activities-button = "always";
        hide-aggregate-menu-arrow = true;
        hide-app-menu-arrow = false;
        hide-app-menu-icon = false;
        hide-dropdown-arrows = false;
        hide-window-titlebars = "never";
        notifications-position = "center";
        reduce-panel-spacing = true;
        restrict-to-primary-screen = false;
        show-desktop-name = true;
        show-legacy-tray = false;
        show-window-buttons = "never";
        show-window-title = "never";
        use-system-fonts = true;
        window-buttons-placement = "auto";
        window-buttons-theme = "yaru";
      };
      "org/gnome/shell/extensions/windowIsReady_Remover".prevent-disable = true;
      "org/gnome/shell/keybindings" = {
        focus-active-notification = [ ];
        screenshot = [ ];
        screenshot-window = [ ];
        show-screenshot-ui = [ ];
        switch-to-application-1 = [ ];
        switch-to-application-2 = [ ];
        switch-to-application-3 = [ ];
        switch-to-application-4 = [ ];
        switch-to-application-5 = [ ];
        switch-to-application-6 = [ ];
        switch-to-application-7 = [ ];
        switch-to-application-8 = [ ];
        switch-to-application-9 = [ ];
        toggle-application-view = [ ];
        toggle-message-tray = [ ];
        toggle-overview = [ "<SUPER>" ];
      };
    };
  };
}
