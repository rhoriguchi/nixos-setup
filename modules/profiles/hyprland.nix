{ pkgs, ... }: {
  nix.settings = {
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
  };

  security.pam.services.hyprlock = { };

  networking.networkmanager.enable = true;

  environment = {
    loginShellInit = ''
      if (( EUID != 0 )) && [[ $- == *i* ]]; then
        if ${pkgs.uwsm}/bin/uwsm check may-start >/dev/null 2>&1; then
          exec ${pkgs.uwsm}/bin/uwsm start hyprland-uwsm.desktop
        fi
      fi
    '';

    sessionVariables.QT_QPA_PLATFORM = "wayland";
  };

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
