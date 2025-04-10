{ config, lib, pkgs, ... }: {
  console.useXkbConfig = true;

  services.xserver.xkb = {
    layout = "ch";
    model = "pc105";
    variant = "de_nodeadkeys";
  };

  programs.dconf.profiles.user.databases = [{
    keyfiles = [ pkgs.gsettings-desktop-schemas ];

    settings."org/gnome/desktop/input-sources".sources = lib.gvariant.mkArray
      [ (lib.gvariant.mkTuple [ "xkb" "${config.services.xserver.xkb.layout}+${config.services.xserver.xkb.variant}" ]) ];
  }];
}
