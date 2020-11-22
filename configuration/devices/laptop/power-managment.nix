{ pkgs, ... }:
let
  acShellScript = pkgs.writeShellScript "ac" ''
    ${pkgs.coreutils}/bin/echo 3 > /sys/devices/platform/asus-nb-wmi/leds/asus::kbd_backlight/brightness
    ${pkgs.coreutils}/bin/echo 24000 > /sys/class/backlight/intel_backlight/brightness
  '';

  batteryShellScript = pkgs.writeShellScript "battery" ''
    ${pkgs.coreutils}/bin/echo 0 > /sys/devices/platform/asus-nb-wmi/leds/asus::kbd_backlight/brightness
    ${pkgs.coreutils}/bin/echo 16000 > /sys/class/backlight/intel_backlight/brightness
  '';
in {
  services.udev.extraRules = ''
    ACTION=="change", SUBSYSTEM=="power_supply", KERNEL=="AC0", ATTR{online}=="1", RUN+="${acShellScript}"
    ACTION=="change", SUBSYSTEM=="power_supply", KERNEL=="AC0", ATTR{online}=="0", RUN+="${batteryShellScript}"
  '';
}
