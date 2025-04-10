{ config, lib, pkgs, ... }: {
  services.fwupd.enable = true;

  environment.systemPackages = lib.optional config.services.xserver.desktopManager.gnome.enable pkgs.gnome-software;
}
