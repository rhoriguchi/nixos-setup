{
  boot.tmp.cleanOnBoot = true;

  programs.dconf.profiles.user.databases = [
    {
      lockAll = true;

      settings."org/gnome/desktop/privacy".remove-old-temp-files = false;
    }
  ];
}
