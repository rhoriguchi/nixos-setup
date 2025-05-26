# TODO HYPRLAND find something better
{ config, pkgs, ... }: {
  wayland.windowManager.hyprland.settings.bind = [ "$mainMod, ESCAPE, exec, ${pkgs.nwg-bar}/bin/nwg-bar" ];

  xdg.configFile."nwg-bar/bar.json".source = (pkgs.formats.json { }).generate "bar.json" [
    {
      label = "Logout";
      exec = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl dispatch exit";
      icon = "${pkgs.nwg-bar}/share/nwg-bar/images/system-lock-screen.svg";
    }
    {
      label = "Suspend";
      exec = "${pkgs.systemd}/bin/systemctl suspend";
      icon = "${pkgs.nwg-bar}/share/nwg-bar/images/system-suspend.svg";
    }
    {
      label = "Shutdown";
      exec = "${pkgs.systemd}/bin/systemctl poweroff";
      # TODO HYPRLAND do i need `-i` which ignores inhibitors
      # exec = "${pkgs.systemd}/bin/systemctl -i poweroff";
      icon = "${pkgs.nwg-bar}/share/nwg-bar/images/system-shutdown.svg";
    }
    {
      label = "Reboot";
      exec = "${pkgs.systemd}/bin/systemctl reboot";
      icon = "${pkgs.nwg-bar}/share/nwg-bar/images/system-reboot.svg";
    }
  ];
}
