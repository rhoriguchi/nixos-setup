{ config, pkgs, ... }:
let
  screenshotsDir = "${config.home.homeDirectory}/Pictures/Screenshots";

  # TODO HYPRLAND kill running instance, extract to lib
  regionScreenshotScript = pkgs.writeShellScript "region-screenshot-script.sh" ''
    LOCKFILE="/tmp/hyprshot.lock"

    if [ -e "$LOCKFILE" ]; then
      exit 1
    fi

    touch "$LOCKFILE"
    trap "rm -f $LOCKFILE" EXIT

    ${pkgs.hyprshot}/bin/hyprshot --output-folder ${screenshotsDir} --mode region
  '';
in {
  # TODO HYPRLAND configure with https://github.com/nix-community/home-manager/blob/master/modules/programs/hyprshot.nix

  home = {
    packages = [
      pkgs.hyprshot

      (pkgs.makeDesktopItem {
        # Use the icon name of `pkgs.gnome-screenshot` so that the icon theme sets an icon
        icon = "org.gnome.Screenshot";
        name = "hyprshot";
        desktopName = "Screenshot";
        keywords = [ "snapshot" "capture" "print" "screenshot" ];
        exec = "${regionScreenshotScript}";
      })
    ];

    activation.createScreenshotsDir = ''
      mkdir -p "${screenshotsDir}"
    '';
  };

  wayland.windowManager.hyprland.settings.bind = [
    # TODO HYPRLAND only captures active windows with background
    ", Print, exec, ${pkgs.hyprshot}/bin/hyprshot --output-folder ${screenshotsDir} --mode active --mode window"
    "SHIFT, Print, exec, ${regionScreenshotScript}"
  ];
}
