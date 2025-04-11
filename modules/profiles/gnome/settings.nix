{ lib, pkgs, ... }:
let
  extensions = [
    pkgs.gnomeExtensions.appindicator
    pkgs.gnomeExtensions.dash-to-dock
    pkgs.gnomeExtensions.launch-new-instance
    pkgs.gnomeExtensions.user-themes
  ];
in {
  environment.systemPackages = [ pkgs.adwaita-fonts pkgs.nerd-fonts.roboto-mono pkgs.papirus-icon-theme pkgs.yaru-theme ];

  programs.dconf = {
    enable = true;

    profiles.user.databases = [
      # Dconf Editor
      {
        settings."ca/desrt/dconf-editor/Settings".show-warning = false;
      }

      # Mission Center
      {
        settings."io/missioncenter/MissionCenter" = {
          performance-page-cpu-graph = lib.gvariant.mkInt32 2;
          performance-page-network-use-bytes = false;
        };
      }

      # Security
      {
        lockAll = true;

        settings = {
          "org/gnome/desktop/notifications".show-in-lock-screen = false;
          "org/gnome/login-screen" = {
            enable-fingerprint-authentication = false;
            enable-smartcard-authentication = false;
          };
        };
      }

      {
        settings = {
          "org/gnome/desktop/interface" = {
            accent-color = "blue";
            font-name = "Adwaita Sans 11";
            gtk-theme = "Yaru-blue";
            icon-theme = "Papirus";
            monospace-font-name = "RobotoMono Nerd Font";
          };
          "org/gnome/desktop/peripherals/touchpad".click-method = "fingers";
          "org/gnome/desktop/privacy".remove-old-trash-files = true;
          "org/gnome/desktop/search-providers".disabled = [ "org.gnome.Contacts.desktop" ];
          "org/gnome/desktop/wm/preferences".titlebar-font = "Adwaita Sans 11";
          "org/gnome/shell" = {
            disable-extension-version-validation = true;
            disable-user-extensions = false;
            disabled-extensions = lib.gvariant.mkEmptyArray lib.gvariant.type.string;
            enabled-extensions =
              map (extension: if lib.hasAttr "extensionUuid" extension then extension.extensionUuid else extension.uuid) extensions;
          };
          "org/gnome/shell/extensions/user-theme".name = "Yaru";
        };
      }
    ];
  };
}
