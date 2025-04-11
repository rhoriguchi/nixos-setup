{ config, pkgs, ... }: {
  services.gnome.sushi.enable = true;

  programs = {
    evince.enable = true;

    file-roller.enable = true;

    dconf = {
      enable = true;

      profiles.user.databases = [{
        keyfiles = [
          "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/gsettings-desktop-schemas-${pkgs.gsettings-desktop-schemas.version}/glib-2.0/schemas"
          "${pkgs.gtk3}/glib-2.0/schemas"
          "${pkgs.nautilus}/glib-2.0/schemas"
        ];

        settings = {
          "org/gnome/desktop/search-providers".sort-order = [ "org.gnome.Nautilus.desktop" ];
          "org/gnome/nautilus/preferences".open-folder-on-dnd-hover = true;
          "org/gtk/settings/file-chooser".show-hidden = true;
        };
      }];
    };
  };

  environment = {
    sessionVariables.NAUTILUS_4_EXTENSION_DIR = "${config.system.path}/lib/nautilus/extensions-4";

    systemPackages = [ pkgs.ffmpegthumbnailer pkgs.gnutar pkgs.nautilus pkgs.zip ];
  };
}
