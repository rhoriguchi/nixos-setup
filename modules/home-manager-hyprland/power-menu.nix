# TODO HYPRLAND find something better
# https://github.com/ArtsyMacaw/wlogout
{
  libCustom,
  osConfig,
  pkgs,
  ...
}:
{
  wayland.windowManager.hyprland.settings.bind = [
    (libCustom.hyprland.mkExecBindRule {
      mods = "SUPER";
      key = "ESCAPE";
      command = "${pkgs.nwg-bar}/bin/nwg-bar";
    })
  ];

  xdg.configFile."nwg-bar/bar.json".source = pkgs.writers.writeJSON "bar.json" [
    {
      label = "Suspend";
      exec = "${osConfig.systemd.package}/bin/systemctl suspend";
      icon = "${pkgs.nwg-bar}/share/nwg-bar/images/system-suspend.svg";
    }
    {
      label = "Shutdown";
      exec = "${osConfig.systemd.package}/bin/systemctl poweroff";
      icon = "${pkgs.nwg-bar}/share/nwg-bar/images/system-shutdown.svg";
    }
    {
      label = "Reboot";
      exec = "${osConfig.systemd.package}/bin/systemctl reboot";
      icon = "${pkgs.nwg-bar}/share/nwg-bar/images/system-reboot.svg";
    }
  ];
}
