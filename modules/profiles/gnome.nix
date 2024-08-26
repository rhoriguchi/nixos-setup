{ pkgs, lib, ... }: {
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
    dconf = {
      enable = true;

      profiles.user.databases = [
        {
          lockAll = true;

          keyfiles = [ pkgs.dconf-editor ];

          settings."ca/desrt/dconf-editor/Settings".show-warning = lib.gvariant.mkBoolean false;
        }
        {
          lockAll = true;

          keyfiles = [ pkgs.mission-center ];

          settings."io/missioncenter/MissionCenter".performance-page-cpu-graph = lib.gvariant.mkInt32 2;
        }
        {
          lockAll = true;

          keyfiles = [ pkgs.gsettings-desktop-schemas ];

          settings."org/gnome/desktop/interface" = {
            font-name = lib.gvariant.mkString "Inter Variable 11";
            monospace-font-name = lib.gvariant.mkString "RobotoMono Nerd Font";
          };
        }
      ];
    };

    gnome-disks.enable = true;
  };

  environment = {
    sessionVariables.QT_QPA_PLATFORM = "wayland";

    systemPackages = [ pkgs.inter (pkgs.nerdfonts.override { fonts = [ "RobotoMono" ]; }) ]
      ++ [ pkgs.dconf-editor pkgs.networkmanager-openconnect ] ++ [
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
      pkgs.loupe
      pkgs.simple-scan
      pkgs.snapshot
    ];
  };
}
