{ config, pkgs, ... }: {
  services.gnome.sushi.enable = true;

  programs = {
    evince.enable = true;

    file-roller.enable = true;

    dconf = {
      enable = true;

      profiles.user.databases = [
        {
          lockAll = true;

          keyfiles = [ pkgs.gsettings-desktop-schemas pkgs.nautilus ];

          settings = {
            "org/gnome/nautilus/preferences".open-folder-on-dnd-hover = true;
            "org/gnome/desktop/search-providers".sort-order = [ "org.gnome.Nautilus.desktop" ];
          };
        }
        {
          keyfiles = [ pkgs.gtk3 ];

          settings."org/gtk/settings/file-chooser".show-hidden = true;
        }
      ];
    };
  };

  environment = {
    sessionVariables.NAUTILUS_4_EXTENSION_DIR = "${config.system.path}/lib/nautilus/extensions-4";

    systemPackages = [ pkgs.ffmpegthumbnailer pkgs.gnutar pkgs.nautilus pkgs.zip ];
  };
}
