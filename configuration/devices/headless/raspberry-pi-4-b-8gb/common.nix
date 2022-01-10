{ pkgs, ... }: {
  imports = [ ../common.nix ];

  nixpkgs.system = "aarch64-linux";

  boot = {
    loader = {
      generic-extlinux-compatible.enable = true;
      grub.enable = false;

      raspberryPi = {
        enable = true;
        version = 4;
      };
    };

    kernelPackages = pkgs.linuxPackages_rpi4;
    kernelParams = [ "8250.nr_uarts=1" "console=ttyAMA0,115200" "console=tty1" "cma=128M" ];

    tmpOnTmpfs = true;
  };

  networking.interfaces = {
    eth0.useDHCP = true; # Ethernet
    wlan0.useDHCP = true; # WiFi
  };
}
