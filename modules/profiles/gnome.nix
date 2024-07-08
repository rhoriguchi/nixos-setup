{ pkgs, ... }: {
  services = {
    xserver = {
      enable = true;

      displayManager.gdm.enable = true;

      desktopManager.gnome.enable = true;

      excludePackages = [ pkgs.xterm ];
    };

    gnome = {
      gnome-browser-connector.enable = false;
      gnome-initial-setup.enable = false;
      gnome-online-accounts.enable = false;
      gnome-remote-desktop.enable = false;
      rygel.enable = false;
    };

    udev.packages = [ pkgs.gnome.gnome-settings-daemon ];
  };

  programs = {
    dconf.enable = true;

    gnome-disks.enable = true;
  };

  environment = {
    systemPackages = [ pkgs.dconf-editor pkgs.networkmanager-openconnect ] ++ [
      pkgs.alacritty # pkgs.gnome-console
      pkgs.firefox # pkgs.epiphany
      pkgs.mission-center # pkgs.gnome-system-monitor

      pkgs.baobab
      pkgs.gnome-calculator
      pkgs.loupe
      pkgs.simple-scan
      pkgs.snapshot
    ];

    gnome.excludePackages = [
      pkgs.adwaita-icon-theme
      pkgs.epiphany
      pkgs.evince
      pkgs.file-roller
      pkgs.geary
      pkgs.gnome-calendar
      pkgs.gnome-connections
      pkgs.gnome-console
      pkgs.gnome-font-viewer
      pkgs.gnome-system-monitor
      pkgs.gnome-text-editor
      pkgs.gnome-themes-extra
      pkgs.gnome-tour
      pkgs.gnome-user-docs
      pkgs.gnome.gnome-backgrounds
      pkgs.gnome.gnome-characters
      pkgs.gnome.gnome-clocks
      pkgs.gnome.gnome-contacts
      pkgs.gnome.gnome-logs
      pkgs.gnome.gnome-maps
      pkgs.gnome.gnome-music
      pkgs.gnome.gnome-weather
      pkgs.nautilus
      pkgs.orca
      pkgs.simple-scan
      pkgs.sushi
      pkgs.totem
      pkgs.yelp

      pkgs.baobab
      pkgs.gnome-calculator
      pkgs.loupe
      pkgs.simple-scan
      pkgs.snapshot
    ];
  };
}
