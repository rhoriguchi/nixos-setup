{ lib, pkgs, ... }: {
  xdg.configFile = {
    "autostart/${pkgs.solaar.pname}.desktop".source = "${pkgs.solaar}/share/applications/solaar.desktop";

    "autostart/${pkgs.wpa_supplicant_gui.pname}.desktop".text =
      let content = lib.readFile "${pkgs.wpa_supplicant_gui}/share/applications/wpa_gui.desktop";
      in lib.replaceStrings [ "Exec=wpa_gui" ] [ "Exec=wpa_gui -t" ] content;
  };
}
