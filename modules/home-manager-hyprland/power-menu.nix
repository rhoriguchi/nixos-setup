# TODO HYPRLAND find something better
# https://github.com/ArtsyMacaw/wlogout
{
  osConfig,
  pkgs,
  ...
}:
{
  wayland.windowManager.hyprland.settings.bind = [
    "$mainMod, ESCAPE, exec, ${pkgs.nwg-bar}/bin/nwg-bar"
  ];

  xdg.configFile."nwg-bar/bar.json".source = (pkgs.formats.json { }).generate "bar.json" [
    {
      label = "Suspend";
      exec = "${osConfig.systemd.package}/bin/systemctl suspend";
      icon = "${pkgs.nwg-bar}/share/nwg-bar/images/system-suspend.svg";
    }
    {
      label = "Shutdown";
      exec = "${osConfig.systemd.package}/bin/systemctl poweroff";
      # TODO HYPRLAND do i need `-i` which ignores inhibitors
      # exec = "${config.systemd.package}/bin/systemctl -i poweroff";
      icon = "${pkgs.nwg-bar}/share/nwg-bar/images/system-shutdown.svg";
    }
    {
      label = "Reboot";
      exec = "${osConfig.systemd.package}/bin/systemctl reboot";
      icon = "${pkgs.nwg-bar}/share/nwg-bar/images/system-reboot.svg";
    }
  ];
}
