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
    };

    udev.packages = [ pkgs.gnome.gnome-settings-daemon ];
  };

  programs.dconf.enable = true;

  environment = {
    systemPackages = [ pkgs.gnome.dconf-editor pkgs.gnome.gnome-software pkgs.gnome.networkmanager-openconnect ] ++ [
      pkgs.firefox # pkgs.gnome.epiphany
      pkgs.flameshot # pkgs.gnome.gnome-screenshot
    ];

    gnome.excludePackages = [
      pkgs.gnome-connections
      pkgs.gnome-photos
      pkgs.gnome-tour
      pkgs.gnome.adwaita-icon-theme
      pkgs.gnome.epiphany
      pkgs.gnome.geary
      pkgs.gnome.gnome-backgrounds
      pkgs.gnome.gnome-calendar
      pkgs.gnome.gnome-characters
      pkgs.gnome.gnome-clocks
      pkgs.gnome.gnome-contacts
      pkgs.gnome.gnome-font-viewer
      pkgs.gnome.gnome-logs
      pkgs.gnome.gnome-maps
      pkgs.gnome.gnome-music
      pkgs.gnome.gnome-screenshot
      pkgs.gnome.gnome-themes-extra
      pkgs.gnome.gnome-weather
      pkgs.gnome.simple-scan
      pkgs.gnome.totem
      pkgs.gnome.yelp
      pkgs.orca
    ];
  };
}
