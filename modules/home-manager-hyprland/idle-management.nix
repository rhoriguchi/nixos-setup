{ config, osConfig, ... }:
{
  services.hypridle = {
    enable = true;

    settings = {
      general = {
        lock_cmd = "${config.programs.hyprlock.package}/bin/hyprlock";

        before_sleep_cmd = "${config.programs.hyprlock.package}/bin/hyprlock";
        after_sleep_cmd = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl dispatch dpms on";
      };

      listener = [
        {
          timeout = 5 * 60;
          on-timeout = "${config.programs.hyprlock.package}/bin/hyprlock";
        }
        {
          timeout = 10 * 60;
          on-timeout = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl dispatch dpms off";

          on-resume = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl dispatch dpms on";
        }
        {
          timeout = 1800;
          on-timeout = "${osConfig.systemd.package}/bin/systemctl suspend";
        }
      ];
    };
  };
}
