{
  config,
  libCustom,
  pkgs,
  ...
}:
let
  screenshotsDir = "${config.home.homeDirectory}/Pictures/Screenshots";

  regionScreenshotScript = pkgs.writers.writeBash "screenshot-region.sh" ''
    ${pkgs.procps}/bin/pgrep -u "$USER" hyprshot >/dev/null || ${config.programs.hyprshot.package}/bin/hyprshot --mode region
  '';
in
{
  programs.hyprshot = {
    enable = true;

    saveLocation = screenshotsDir;
  };

  home = {
    packages = [
      (pkgs.makeDesktopItem {
        # Use the icon name of `pkgs.gnome-screenshot` so that the icon theme sets an icon
        icon = "org.gnome.Screenshot";
        name = "hyprshot";
        desktopName = "Screenshot";
        keywords = [
          "snapshot"
          "capture"
          "print"
          "screenshot"
        ];
        exec = "${regionScreenshotScript}";
      })
    ];

    activation.createScreenshotsDir = ''
      mkdir -p "${screenshotsDir}"
    '';
  };

  wayland.windowManager.hyprland.settings.bind = [
    (libCustom.hyprland.mkExecBindRule {
      key = "Print";
      command = "${config.programs.hyprshot.package}/bin/hyprshot --mode active --mode output";
    })
    (libCustom.hyprland.mkExecBindRule {
      mods = "SHIFT";
      key = "Print";
      command = "${regionScreenshotScript}";
    })
  ];
}
