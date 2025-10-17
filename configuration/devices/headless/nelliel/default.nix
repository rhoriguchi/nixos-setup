{
  imports = [
    ../common.nix

    ./hardware-configuration.nix
  ];

  boot.loader.grub = {
    enable = true;

    device = "/dev/sda";
  };

  networking = {
    hostName = "XXLPitu-Nelliel";

    interfaces.enp1s0.useDHCP = true;
  };
}
