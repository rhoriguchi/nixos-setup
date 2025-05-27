{ pkgs, ... }: {
  imports = [ ./settings.nix ];

  # TODO remove when https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-2495681673 fixed
  systemd.services = {
    "getty@tty1".enable = false;
    "autovt@tty1".enable = false;
  };

  services = {
    displayManager.defaultSession = "gnome";

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

    udev.packages = [ pkgs.gnome-settings-daemon ];
  };

  programs.gnome-disks.enable = true;

  environment = {
    sessionVariables.QT_QPA_PLATFORM = "wayland";

    systemPackages = [ pkgs.dconf-editor pkgs.networkmanager-openconnect ] ++ [
      pkgs.firefox # pkgs.epiphany
      pkgs.ghostty # pkgs.gnome-console
      pkgs.mission-center # pkgs.gnome-system-monitor

      pkgs.baobab
      pkgs.gnome-calculator
      pkgs.gnome-shell-extensions
      pkgs.loupe
      pkgs.snapshot
    ];

    gnome.excludePackages = [
      pkgs.adwaita-fonts
      pkgs.adwaita-icon-theme
      pkgs.decibels
      pkgs.epiphany
      pkgs.evince
      pkgs.file-roller
      pkgs.geary
      pkgs.gnome-backgrounds
      pkgs.gnome-calendar
      pkgs.gnome-characters
      pkgs.gnome-clocks
      pkgs.gnome-connections
      pkgs.gnome-console
      pkgs.gnome-contacts
      pkgs.gnome-font-viewer
      pkgs.gnome-logs
      pkgs.gnome-maps
      pkgs.gnome-music
      pkgs.gnome-system-monitor
      pkgs.gnome-text-editor
      pkgs.gnome-themes-extra
      pkgs.gnome-tour
      pkgs.gnome-user-docs
      pkgs.gnome-weather
      pkgs.nautilus
      pkgs.orca
      pkgs.simple-scan
      pkgs.sushi
      pkgs.totem
      pkgs.yelp

      pkgs.baobab
      pkgs.gnome-calculator
      pkgs.gnome-shell-extensions
      pkgs.loupe
      pkgs.snapshot
    ];
  };
}
