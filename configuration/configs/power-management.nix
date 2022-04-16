{
  boot.kernelModules = [ "coretemp" "cpuid" ];

  services = {
    power-profiles-daemon.enable = false;

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
