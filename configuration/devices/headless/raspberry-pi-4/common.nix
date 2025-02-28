{ lib, pkgs, ... }: {
  imports = [ ../common.nix ./hardware-configuration.nix ];

  boot = {
    kernelPackages = lib.mkForce pkgs.linuxKernel.packages.linux_rpi4;

    # fixes connection issue with wpa_supplicant v2.11
    # https://github.com/raspberrypi/bookworm-feedback/issues/121
    extraModprobeConfig = ''
      options brcmfmac feature_disable=0x2000
    '';

    # https://github.com/NixOS/nixos-hardware/issues/858
    # https://github.com/NixOS/nixpkgs/issues/344963
    initrd.systemd.tpm2.enable = false;
  };

  networking.interfaces = {
    eth0.useDHCP = true; # Ethernet
    wlan0.useDHCP = true; # WiFi
  };

  environment.systemPackages = [ pkgs.raspberrypi-eeprom ];

  # https://github.com/fwupd/fwupd/wiki/PluginFlag:capsules-unsupported
  services.fwupd.daemonSettings.DisabledPlugins = [ "test" "test_ble" "invalid" "bios" ];
}
