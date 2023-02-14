{ pkgs, ... }: {
  i18n = {
    defaultLocale = "en_US.UTF-8";

    extraLocaleSettings = {
      LC_COLLATE = "en_US.UTF-8";
      LC_MEASUREMENT = "de_CH.UTF-8";
      LC_MESSAGES = "en_US.UTF-8";
      LC_MONETARY = "de_CH.UTF-8";
      LC_NUMERIC = "de_CH.UTF-8";
      LC_PAPER = "de_CH.UTF-8";
      LC_TIME = "en_GB.UTF-8";
    };
  };

  services.xserver.desktopManager.gnome = {
    extraGSettingsOverrides = ''
      [system.locale]
      region='de_CH.UTF-8'
    '';

    extraGSettingsOverridePackages = [
      pkgs.gsettings-desktop-schemas # system.locale
    ];
  };
}
