{ pkgs, ... }: {
  # TODO HYPRLAND move all to special workspace which is hidden https://wiki.hyprland.org/Configuring/Dispatchers/#special-workspace
  wayland.windowManager.hyprland.settings.exec-once = [ "${pkgs.dex}/bin/dex --autostart --environment Hyprland" ];
}
