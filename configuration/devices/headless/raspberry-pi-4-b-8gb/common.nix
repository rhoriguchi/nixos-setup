{ pkgs, ... }: {
  imports = [ ../common.nix ./hardware-configuration.nix ];

  boot.loader.raspberryPi.firmwareConfig = ''
    hdmi_force_hotplug=1
  '';

  networking.interfaces = {
    eth0.useDHCP = true; # Ethernet
    wlan0.useDHCP = true; # WiFi
  };

  environment.systemPackages = [ pkgs.raspberrypi-eeprom ];
}
