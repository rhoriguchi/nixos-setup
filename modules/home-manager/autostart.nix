{ lib, pkgs, ... }: {
  xdg.autostart = {
    readOnly = true;

    entries = [
      "${pkgs.solaar}/share/applications/solaar.desktop"

      (let content = lib.readFile "${pkgs.wpa_supplicant_gui}/share/applications/wpa_gui.desktop";
      in lib.replaceStrings [ "Exec=wpa_gui" ] [ "Exec=wpa_gui -t" ] content)
    ];
  };
}
