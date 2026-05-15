{
  config,
  lib,
  libCustom,
  osConfig,
  pkgs,
  ...
}:
let
  displayOn = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl dispatch '${
    lib.replaceStrings [ "\n" ] [ " " ]
      (libCustom.hyprland._mkLuaCommand {
        dispatcher = "dpms";
        args = "enable";
      }).expr
  }'";
  displayOff = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl dispatch '${
    lib.replaceStrings [ "\n" ] [ " " ]
      (libCustom.hyprland._mkLuaCommand {
        dispatcher = "dpms";
        args = "disable";
      }).expr
  }'";

  keyboardBacklightOn = ''${pkgs.brightnessctl}/bin/brightnessctl -rd "$(basename /sys/class/leds/*::kbd_backlight)"'';
  keyboardBacklightOff = ''${pkgs.brightnessctl}/bin/brightnessctl -sd "$(basename /sys/class/leds/*::kbd_backlight)" set 0'';
in
{
  services.hypridle = {
    enable = true;

    settings = {
      general = {
        lock_cmd = "${pkgs.procps}/bin/pidof hyprlock || ${config.programs.hyprlock.package}/bin/hyprlock";

        before_sleep_cmd = "${osConfig.systemd.package}/bin/loginctl lock-session";
        after_sleep_cmd = lib.concatStringsSep " && " [
          displayOn
          keyboardBacklightOn
        ];
      };

      listener = [
        {
          timeout = 5 * 60;
          on-timeout = "${osConfig.systemd.package}/bin/loginctl lock-session";
        }

        {
          timeout = 10 * 60;
          on-timeout = displayOff;
          on-resume = displayOn;
        }
        {
          timeout = 10 * 60;
          on-timeout = keyboardBacklightOff;
          on-resume = keyboardBacklightOn;
        }

        {
          timeout = 30 * 60;
          on-timeout = "${osConfig.systemd.package}/bin/systemctl suspend";
        }
      ];
    };
  };
}
