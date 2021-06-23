{ pkgs, ... }: {
  imports = [ ../common.nix ];

  boot = {
    kernelPackages = pkgs.linuxPackages_rpi4;
    kernelParams = [ "8250.nr_uarts=1" "console=ttyAMA0,115200" "console=tty1" "cma=128M" ];

    loader = {
      grub.enable = false;

      raspberryPi = {
        enable = true;
        version = 4;
      };
    };
  };

  hardware.enableRedistributableFirmware = true;

  networking.interfaces = {
    eth0.useDHCP = true; # Ethernet
    wlan0.useDHCP = true; # WiFi
  };
}
