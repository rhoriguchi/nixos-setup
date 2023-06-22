{ config, pkgs, ... }:
let screenshotsDir = "${config.home.homeDirectory}/Pictures/Screenshots";
in {
  home.activation.createScreenshotsDir = ''
    ${pkgs.coreutils}/bin/mkdir -p "${screenshotsDir}"
  '';

  # TODO can be called multiple times
  wayland.windowManager.hyprland.extraConfig = ''
    bind = , Print, exec, ${pkgs.sway-contrib.grimshot}/bin/grimshot --notify copy area
    bind = SHIFT, Print, exec, ${pkgs.sway-contrib.grimshot}/bin/grimshot --notify save area "${screenshotsDir}/$(${pkgs.coreutils-full}/bin/date --iso-8601=minutes).png"
  '';
}
