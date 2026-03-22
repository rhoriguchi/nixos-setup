{ pkgs, ... }:
{
  imports = [
    ../common.nix
    ./hardware-configuration.nix
  ];

  hardware.raspberry-pi.config.all.options = {
    # Fix boot issue if no hdmi input detected
    # https://www.raspberrypi.com/documentation/computers/legacy_config_txt.html#hdmi_force_hotplug
    "hdmi_force_hotplug" = {
      value = "1";
      enable = true;
    };
  };

  networking.interfaces = {
    eth0.useDHCP = true; # Ethernet
    wlan0.useDHCP = true; # WiFi
  };

  environment.systemPackages = [ pkgs.raspberrypi-eeprom ];
}
