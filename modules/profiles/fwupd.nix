{ pkgs, lib, config, ... }: {
  services.fwupd.enable = true;

  environment.systemPackages = lib.optional config.services.xserver.enable pkgs.gnome.gnome-software;
}

