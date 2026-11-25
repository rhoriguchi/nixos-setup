{ config, pkgs, ... }:
{
  security.pam.services.hyprlock.enableGnomeKeyring = config.services.gnome.gnome-keyring.enable;

  networking.networkmanager.enable = true;

  environment = {
    sessionVariables.QT_QPA_PLATFORM = "wayland;xcb";

    systemPackages = [
      (pkgs.symlinkJoin {
        inherit (pkgs.kitty) name pname version;
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
      inherit (pkgs.uwsm) name pname version;
      paths = [ pkgs.uwsm ];

      postBuild = ''
        rm $out/share/applications/uuctl.desktop
      '';

      meta.mainProgram = pkgs.uwsm.meta.mainProgram;
    };
  };

  nixpkgs.overlays = [
    (_: prev: {
      # Required for Signal to work with GNOME Keyring
      signal-desktop =
        let
          package = prev.signal-desktop;
        in
        prev.symlinkJoin {
          inherit (package) name pname version;
          paths = [ package ];

          nativeBuildInputs = [ prev.makeWrapper ];

          postBuild = ''
            wrapProgram $out/bin/${package.meta.mainProgram} \
              --set XDG_CURRENT_DESKTOP "GNOME"
          '';
        };

      # Required for JetBrains IDEs to use GNOME Keyring
      jetbrains =
        prev.jetbrains
        // prev.lib.genAttrs [ "idea" "idea-oss" "pycharm" "pycharm-oss" ] (
          name:
          let
            package = prev.jetbrains.${name};
          in
          prev.symlinkJoin {
            inherit (package) name pname version;
            paths = [ package ];

            nativeBuildInputs = [ prev.makeWrapper ];

            postBuild = ''
              wrapProgram $out/bin/${package.meta.mainProgram} \
                --set XDG_CURRENT_DESKTOP "GNOME"
            '';

            meta.mainProgram = package.meta.mainProgram;
          }
        );
    })
  ];
}
