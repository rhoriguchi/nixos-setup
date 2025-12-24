{ config, pkgs, ... }:
{
  security.pam.services.hyprlock.enableGnomeKeyring = config.services.gnome.gnome-keyring.enable;

  networking.networkmanager.enable = true;

  environment = {
    sessionVariables.QT_QPA_PLATFORM = "wayland";

    systemPackages = [
      (pkgs.symlinkJoin {
        inherit (pkgs.kitty) name;
        paths = [ pkgs.kitty ];

        postBuild = ''
          rm $out/share/applications/kitty.desktop
        '';

        meta.mainProgram = pkgs.kitty.meta.mainProgram;
      })
    ];
  };

  xdg.portal.extraPortals = [
    # org.freedesktop.portal.FileChooser
    # org.freedesktop.portal.OpenURI
    # org.freedesktop.portal.Print
    # org.freedesktop.portal.Settings
    pkgs.xdg-desktop-portal-gtk
  ];

  services = {
    displayManager = {
      defaultSession = "hyprland-uwsm";

      sddm = {
        enable = true;

        wayland.enable = true;
      };
    };

    gnome = {
      gnome-keyring.enable = true;

      gcr-ssh-agent.enable = false;
    };

    logind.settings.Login = {
      HandlePowerKey = "suspend";
      HandlePowerKeyLongPress = "poweroff";
      HandleLidSwitch = "suspend";
    };

    pipewire.enable = true;

    udisks2.enable = true;
  };

  programs = {
    ssh.startAgent = true;

    dconf.enable = true;

    gnome-disks.enable = true; # pkgs.gnome-disk-utility

    seahorse.enable = true;

    hyprland = {
      enable = true;

      withUWSM = true;
    };

    uwsm.package = pkgs.symlinkJoin {
      inherit (pkgs.uwsm) name;
      paths = [ pkgs.uwsm ];

      postBuild = ''
        rm $out/share/applications/uuctl.desktop
      '';

      meta.mainProgram = pkgs.uwsm.meta.mainProgram;
    };
  };

  nixpkgs.overlays = [
    (_: super: {
      # Required for Signal to work with GNOME Keyring
      signal-desktop = super.symlinkJoin {
        inherit (super.signal-desktop) name;
        paths = [ super.signal-desktop ];

        nativeBuildInputs = [ super.makeWrapper ];

        postBuild = ''
          wrapProgram $out/bin/signal-desktop \
            --set XDG_CURRENT_DESKTOP "GNOME"
        '';
      };
    })
  ];
}
