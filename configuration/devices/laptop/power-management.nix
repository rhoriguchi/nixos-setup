{ pkgs, ... }:
let
  # TODO add rule to modify org.gnome.desktop.session idle-delay (gsettings does not work)

  acShellScript = pkgs.writeShellScript "ac" ''
    echo 3 > /sys/devices/platform/asus-nb-wmi/leds/asus::kbd_backlight/brightness
    echo 24000 > /sys/class/backlight/intel_backlight/brightness
  '';

  batteryShellScript = pkgs.writeShellScript "battery" ''
    echo 0 > /sys/devices/platform/asus-nb-wmi/leds/asus::kbd_backlight/brightness
    echo 16000 > /sys/class/backlight/intel_backlight/brightness
  '';
in {
  services.udev.extraRules = ''
    ACTION=="change", SUBSYSTEM=="power_supply", KERNEL=="AC0", ATTR{online}=="1", RUN+="${acShellScript}"
    ACTION=="change", SUBSYSTEM=="power_supply", KERNEL=="AC0", ATTR{online}=="0", RUN+="${batteryShellScript}"
  '';

  boot.kernelModules = [ "coretemp" "cpuid" ];

  services = {
    thermald.enable = true;

    tlp = {
      enable = true;
      settings = {
        USB_BLACKLIST_BTUSB = "1";
        USB_BLACKLIST_PHONE = "0";

        CPU_BOOST_ON_AC = "1";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        MAX_LOST_WORK_SECS_ON_AC = "15";
        WIFI_PWR_ON_AC = "off";

        CPU_BOOST_ON_BAT = "0";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        MAX_LOST_WORK_SECS_ON_BAT = "30";
        WIFI_PWR_ON_BAT = "off";
      };
    };
  };
}
