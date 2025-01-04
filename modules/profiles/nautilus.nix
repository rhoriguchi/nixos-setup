{ config, lib, pkgs, ... }: {
  services.gnome.sushi.enable = true;

  programs = {
    evince.enable = true;

    file-roller.enable = true;

    dconf = {
      enable = true;

      profiles.user.databases = [
        {
          lockAll = true;

          keyfiles = [ pkgs.nautilus ];

          settings."org/gnome/nautilus/preferences".open-folder-on-dnd-hover = lib.gvariant.mkBoolean true;
        }
        {
          keyfiles = [ pkgs.gtk3 ];

          settings."org/gtk/settings/file-chooser".show-hidden = lib.gvariant.mkBoolean true;
        }
      ];
    };
  };

  environment = {
    sessionVariables.NAUTILUS_4_EXTENSION_DIR = "${config.system.path}/lib/nautilus/extensions-4";

    systemPackages = [ pkgs.ffmpegthumbnailer pkgs.gnutar pkgs.nautilus pkgs.zip ];
  };
}
