{ pkgs, lib, config, ... }:
let packages = lib.unique (map (package: package.name) (config.environment.systemPackages ++ config.users.users.rhoriguchi.packages));
in {
  home-manager.users.rhoriguchi.xdg.configFile = {
    "autostart/discord.desktop" = lib.mkIf (lib.elem pkgs.discord.name packages) {
      text = ''
        ${lib.readFile "${pkgs.discord}/share/applications/discord.desktop"}
        X-GNOME-Autostart-enabled=true
      '';
    };

    "autostart/flameshot.desktop" = lib.mkIf (lib.elem pkgs.flameshot.name packages) {
      text = ''
        [Desktop Entry]
        Name=flameshot
        Icon=flameshot
        Exec=${pkgs.flameshot}/bin/flameshot
        Terminal=false
        Type=Application
        X-GNOME-Autostart-enabled=true
      '';
    };

    "autostart/protonvpn-tray.desktop" = lib.mkIf (lib.elem pkgs.protonvpn-gui.name packages) {
      text = ''
        ${lib.readFile "${pkgs.protonvpn-gui}/share/applications/protonvpn-tray.desktop"}
        X-GNOME-Autostart-enabled=true
      '';
    };

    "autostart/signal-desktop.desktop" = lib.mkIf (lib.elem pkgs.signal-desktop.name packages) {
      text = ''
        ${lib.readFile "${pkgs.signal-desktop}/share/applications/signal-desktop.desktop"}
        X-GNOME-Autostart-enabled=true
      '';
    };
  };
}
