{ pkgs, lib, ... }: {
  xdg.configFile = {
    "autostart/${pkgs.discord.pname}.desktop".source = "${pkgs.discord}/share/applications/discord.desktop";

    "autostart/${pkgs.flameshot.pname}.desktop".text =
      let content = lib.readFile "${pkgs.flameshot}/share/applications/org.flameshot.Flameshot.desktop";
      in lib.replaceStrings [ "/usr/bin/flameshot" ] [ "flameshot" ] content;

    "autostart/${pkgs.signal-desktop.pname}.desktop".source = "${pkgs.signal-desktop}/share/applications/signal-desktop.desktop";

    "autostart/${pkgs.wpa_supplicant_gui.pname}.desktop".text =
      let content = lib.readFile "${pkgs.wpa_supplicant_gui}/share/applications/wpa_gui.desktop";
      in lib.replaceStrings [ "Exec=wpa_gui" ] [ "Exec=wpa_gui -t" ] content;
  };
}
