{ pkgs, ... }: {
  home-manager.users.rhoriguchi.home.file = {
    ".config/autostart/org.flameshot.Flameshot.desktop.desktop".source =
      "${pkgs.flameshot}/share/applications/org.flameshot.Flameshot.desktop";
    ".config/autostart/megasync.desktop".source =
      "${pkgs.megasync}/share/applications/megasync.desktop";
  };
}
