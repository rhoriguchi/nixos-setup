{ pkgs, ... }: {
  boot.tmp.cleanOnBoot = true;

  programs.dconf.profiles.user.databases = [{
    lockAll = true;

    keyfiles = [
      "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/gsettings-desktop-schemas-${pkgs.gsettings-desktop-schemas.version}/glib-2.0/schemas"
    ];

    settings."org/gnome/desktop/privacy".remove-old-temp-files = false;
  }];
}
