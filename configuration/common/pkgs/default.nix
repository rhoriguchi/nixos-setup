[
  (self: super: {
    mach-nix = super.callPackage ./mach-nix.nix { pkgs = super; };
  })
  (self: super: {
    displaylink = super.callPackage ./displaylink {
      inherit (super) displaylink;
      inherit (super.linuxPackages) evdi;
    };
    glances = super.callPackage ./glances.nix { inherit (super) glances; };
    protonvpn-cli =
      super.callPackage ./protonvpn-cli { inherit (super) protonvpn-cli; };
    mal_export = super.callPackage ./mal_export.nix { };
    tv_time_export = super.callPackage ./tv_time_export.nix { };

    megasync = super.callPackage ./megasync.nix { };
    teamviewer = super.callPackage ./teamviewer.nix { };
  })
  (self: super: {
    # TODO do not work
    # discord = super.makeAutostartItem {
    #   package = super.discord;
    #   name = "discord";
    # };
    # flameshot = super.makeAutostartItem {
    #   package = super.flameshot;
    #   srcPrefix = "org.flameshot";
    #   name = "Flameshot";
    # };
    # megasync = super.makeAutostartItem {
    #   package = super.megasync;
    #   name = "megasync";
    # };
    signal-desktop = super.makeAutostartItem {
      package = super.signal-desktop;
      name = "signal-desktop";
    };
  })
  # TODO add hook to set 'NoDisplay=true'
  # (
  #   cups # cups.desktop
  #   gnome3.gnome-logs # org.gnome.Logs.desktop
  #   xterm # xterm.desktop
  #   hplip # hplip.desktop
  #   nvidia-settings # nvidia-settings.desktop

  #   # not sure overwriting libreoffice works for libreoffice-fresh
  #   libreoffice # startcenter.desktop base.desktop draw.desktop math.desktop
  # )
]
