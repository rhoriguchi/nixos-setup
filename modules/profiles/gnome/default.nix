{ pkgs, ... }:
{
  imports = [ ./settings.nix ];

  services = {
    displayManager = {
      defaultSession = "gnome";

      gdm.enable = true;
    };

    desktopManager.gnome.enable = true;

    xserver = {
      enable = true;

      excludePackages = [ pkgs.xterm ];
    };

    gnome = {
      gnome-browser-connector.enable = false;
      gnome-initial-setup.enable = false;
      gnome-online-accounts.enable = false;
      gnome-remote-desktop.enable = false;
    };

    udev.packages = [ pkgs.gnome-settings-daemon ];
  };

  programs = {
    gnome-disks.enable = true; # pkgs.gnome-disk-utility
    seahorse.enable = true; # pkgs.seahorse
  };

  environment = {
    sessionVariables.QT_QPA_PLATFORM = "wayland";

    systemPackages = [ pkgs.gnome-shell-extensions ];

    gnome.excludePackages = [
      pkgs.adwaita-fonts
      pkgs.adwaita-icon-theme
      pkgs.baobab
      pkgs.decibels
      pkgs.epiphany
      pkgs.file-roller
      pkgs.geary
      pkgs.gnome-backgrounds
      pkgs.gnome-calculator
      pkgs.gnome-calendar
      pkgs.gnome-characters
      pkgs.gnome-clocks
      pkgs.gnome-connections
      pkgs.gnome-console
      pkgs.gnome-contacts
      pkgs.gnome-disk-utility
      pkgs.gnome-font-viewer
      pkgs.gnome-logs
      pkgs.gnome-maps
      pkgs.gnome-music
      pkgs.gnome-shell-extensions
      pkgs.gnome-system-monitor
      pkgs.gnome-text-editor
      pkgs.gnome-themes-extra
      pkgs.gnome-tour
      pkgs.gnome-user-docs
      pkgs.gnome-weather
      pkgs.loupe
      pkgs.nautilus
      pkgs.orca
      pkgs.papers
      pkgs.seahorse
      pkgs.simple-scan
      pkgs.snapshot
      pkgs.sushi
      pkgs.totem
      pkgs.yelp
    ];
  };
}
