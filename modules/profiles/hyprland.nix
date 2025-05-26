{ config, pkgs, ... }: {
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
    # TODO HYPERLAND this seems to cause issues with tty
    getty.autologinUser = config.services.displayManager.autoLogin.user;

    gnome.gnome-keyring.enable = true;

    logind = {
      powerKey = "suspend";
      powerKeyLongPress = "poweroff";
      lidSwitch = "suspend";
    };

    pipewire.enable = true;
  };

  programs = {
    dconf.enable = true;

    gnome-disks.enable = true; # pkgs.gnome-disk-utility

    seahorse.enable = true;

    hyprland = {
      enable = true;

      withUWSM = true;
    };
  };
}
