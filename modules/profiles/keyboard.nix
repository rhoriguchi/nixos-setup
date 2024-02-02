{ pkgs, ... }: {
  console.useXkbConfig = true;

  services.xserver = rec {
    xkb = {
      layout = "ch";
      model = "pc105";
      variant = "de_nodeadkeys";
    };

    desktopManager.gnome = {
      extraGSettingsOverrides = ''
        [org.gnome.desktop.input-sources]
        sources=[ ('xkb', '${xkb.layout}+${xkb.variant}') ]
      '';

      extraGSettingsOverridePackages = [
        pkgs.gsettings-desktop-schemas # org.gnome.desktop.input-sources
      ];
    };
  };
}
