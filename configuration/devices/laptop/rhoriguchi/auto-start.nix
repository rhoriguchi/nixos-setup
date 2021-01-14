{ pkgs, ... }: {
  home-manager.users.rhoriguchi.home.file = with pkgs; {
    ".config/autostart/${flameshot.pname}.desktop".source =
      "${flameshot}/share/applications/org.flameshot.Flameshot.desktop";
    ".config/autostart/${megasync.pname}.desktop".source =
      "${megasync}/share/applications/megasync.desktop";
    ".config/autostart/${signal-desktop.pname}.desktop".source =
      "${signal-desktop}/share/applications/signal-desktop.desktop";
  };
}
