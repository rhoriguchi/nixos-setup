{ lib, pkgs, ... }:
{
  services = {
    gnome.sushi.enable = true;

    gvfs.enable = true;
  };

  programs.dconf = {
    enable = true;

    profiles.user.databases = [
      {
        settings = {
          "org/gnome/desktop/search-providers".sort-order = [ "org.gnome.Nautilus.desktop" ];
          "org/gnome/nautilus/preferences".open-folder-on-dnd-hover = true;
          "org/gtk/settings/file-chooser".show-hidden = true;
        };
      }
    ];
  };

  environment = {
    # Required for audio / video information https://github.com/NixOS/nixpkgs/issues/53631
    sessionVariables.GST_PLUGIN_SYSTEM_PATH_1_0 = lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" [
      pkgs.gst_all_1.gst-plugins-good
      pkgs.gst_all_1.gst-plugins-bad
      pkgs.gst_all_1.gst-plugins-ugly
      pkgs.gst_all_1.gst-libav
    ];

    systemPackages = [
      pkgs.file-roller
      pkgs.ffmpegthumbnailer
      pkgs.gnutar
      pkgs.nautilus
      pkgs.zip
    ];
  };
}
