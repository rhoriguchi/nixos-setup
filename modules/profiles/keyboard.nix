{ pkgs, ... }: {
  console.useXkbConfig = true;

  services.xserver = rec {
    layout = "ch";
    xkbModel = "pc105";
    xkbVariant = "de_nodeadkeys";

    desktopManager.gnome = {
      extraGSettingsOverrides = ''
        [org.gnome.desktop.input-sources]
        sources=[ ('xkb', '${layout}+${xkbVariant}') ]
      '';

      extraGSettingsOverridePackages = [
        pkgs.gsettings-desktop-schemas # org.gnome.desktop.input-sources
      ];
    };
  };
}
