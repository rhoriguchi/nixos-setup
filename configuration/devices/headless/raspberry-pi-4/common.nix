{ lib, pkgs, ... }: {
  imports = [ ../common.nix ./hardware-configuration.nix ];

  boot.kernelPackages = lib.mkForce pkgs.linuxKernel.packages.linux_rpi4;

  networking.interfaces = {
    eth0.useDHCP = true; # Ethernet
    wlan0.useDHCP = true; # WiFi
  };

  environment.systemPackages = [ pkgs.raspberrypi-eeprom ];
}
