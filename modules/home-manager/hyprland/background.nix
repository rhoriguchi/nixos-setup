{ pkgs, ... }: {
  wayland.windowManager.hyprland.extraConfig = ''
    exec-once = ${pkgs.swaybg}/bin/swaybg --image ${./wallpaper.jpg}
  '';
}
