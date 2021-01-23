{ pkgs, lib, ... }:
let
  applications = with pkgs; [
    {
      package = flameshot;
      desktop = "org.flameshot.Flameshot.desktop";
    }
    {
      package = megasync;
      desktop = "megasync.desktop";
    }
    {
      package = signal-desktop;
      desktop = "signal-desktop.desktop";
    }
    {
      package = teamviewer;
      desktop = "com.teamviewer.TeamViewer.desktop";
    }
  ];
in {
  home-manager.users.rhoriguchi.home.file = lib.mkMerge (map (application: {
    ".config/autostart/${application.package.pname}.desktop".source =
      "${application.package}/share/applications/${application.desktop}";
  }) applications);
}
