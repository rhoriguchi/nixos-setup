{ config, pkgs, ... }:
{
  security.pam.services.hyprlock.enableGnomeKeyring = config.services.gnome.gnome-keyring.enable;

  networking.networkmanager.enable = true;

  environment = {
    loginShellInit = ''
      if (( EUID != 0 )) && [[ $- == *i* ]]; then
        if ${config.programs.uwsm.package}/bin/uwsm check may-start >/dev/null 2>&1; then
          exec ${config.programs.uwsm.package}/bin/uwsm start hyprland-uwsm.desktop
        fi
      fi
    '';

    sessionVariables.QT_QPA_PLATFORM = "wayland";
  };

  xdg.portal.extraPortals = [
    # org.freedesktop.portal.FileChooser
    # org.freedesktop.portal.OpenURI
    # org.freedesktop.portal.Print
    # org.freedesktop.portal.Settings
    pkgs.xdg-desktop-portal-gtk
  ];

  services = {
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

      uwsm = super.symlinkJoin {
        inherit (super.uwsm) name;
        paths = [ super.uwsm ];

        postBuild = ''
          rm $out/share/applications/uuctl.desktop
        '';

        meta.mainProgram = super.uwsm.meta.mainProgram;
      };
    })
  ];
}
