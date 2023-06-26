{ pkgs, config, ... }: {
  services.gnome.sushi.enable = true;

  programs = {
    evince.enable = true;

    file-roller.enable = true;
  };

  environment = {
    sessionVariables.NAUTILUS_4_EXTENSION_DIR = "${config.system.path}/lib/nautilus/extensions-4";

    systemPackages = [ pkgs.ffmpegthumbnailer pkgs.gnome.nautilus pkgs.gnutar pkgs.zip ];
  };
}
