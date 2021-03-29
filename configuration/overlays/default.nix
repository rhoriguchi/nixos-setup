[
  (self: super: {
    mach-nix = let
      commit = "3.2.0";
      sha256 = "0qhg36l3c1i6p0p2l346fpj9zsh5kl0xpjmyasi1qcn7mbdfjb0m";
    in import (fetchTarball {
      url = "https://github.com/DavHau/mach-nix/archive/${commit}.tar.gz";
      inherit sha256;
    }) { pkgs = super; };
  })
  (self: super: {
    displaylink = super.callPackage ./displaylink {
      inherit (super) displaylink;
      inherit (super.linuxPackages) evdi;
    };
    glances = super.callPackage ./glances.nix { inherit (super) glances; };
    protonvpn-cli = super.callPackage ./protonvpn-cli { inherit (super) protonvpn-cli; };
    tv_time_export = super.callPackage ./tv_time_export.nix { };

    # TODO temp fix till in pkgs https://github.com/NixOS/nixpkgs/pull/117435
    discord = super.callPackage ./discord.nix { inherit (super) discord; };

    # TODO temp fix till resolved or never version released https://github.com/NixOS/nixpkgs/issues/96633
    teamviewer = super.callPackage ./teamviewer.nix { inherit (super) teamviewer; };
  })

  # # TODO do not work
  # (self: super: {
  #   discord = super.makeAutostartItem {
  #     package = super.discord;
  #     name = "discord";
  #   };
  #   flameshot = super.makeAutostartItem {
  #     package = super.flameshot;
  #     srcPrefix = "org.flameshot";
  #     name = "Flameshot";
  #   };
  #   megasync = super.makeAutostartItem {
  #     package = super.megasync;
  #     name = "megasync";
  #   };
  #   signal-desktop = super.makeAutostartItem {
  #     package = super.signal-desktop;
  #     name = "signal-desktop";
  #   };
  # })

  # TODO add hook to set 'NoDisplay=true'
  # gnome3.gnome-logs # org.gnome.Logs.desktop
  # xterm # xterm.desktop
  # hplip # hplip.desktop
  # nvidia-settings # nvidia-settings.desktop
  #
  # not sure overwriting libreoffice works for libreoffice-fresh
  # libreoffice # startcenter.desktop base.desktop draw.desktop math.desktop
]
