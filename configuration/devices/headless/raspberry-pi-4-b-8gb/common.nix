{ pkgs, ... }: {
  imports = [ ../common.nix ./hardware-configuration.nix ];

  nixpkgs.system = "aarch64-linux";

  boot.kernelPackages = pkgs.linuxPackages_rpi4;

  networking.interfaces = {
    eth0.useDHCP = true; # Ethernet
    wlan0.useDHCP = true; # WiFi
  };

  environment.systemPackages = [ pkgs.raspberrypi-eeprom ];
}
