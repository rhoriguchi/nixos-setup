{ pkgs, lib, config, ... }:
let packages = lib.unique (map (p: "${p.name}") (config.environment.systemPackages ++ config.users.users.rhoriguchi.packages));
in {
  home-manager.users.rhoriguchi.xdg.configFile = {
    "autostart/discord.desktop" = lib.mkIf (builtins.elem pkgs.discord.name packages) {
      text = ''
        ${builtins.readFile "${pkgs.discord}/share/applications/discord.desktop"}
        X-GNOME-Autostart-enabled=true
      '';
    };

    "autostart/flameshot.desktop" = lib.mkIf (builtins.elem pkgs.flameshot.name packages) {
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

    "autostart/megasync.desktop" = lib.mkIf (builtins.elem pkgs.megasync.name packages) {
      text = ''
        ${builtins.readFile "${pkgs.megasync}/share/applications/megasync.desktop"}
        X-GNOME-Autostart-enabled=true
      '';
    };

    "autostart/signal-desktop.desktop" = lib.mkIf (builtins.elem pkgs.signal-desktop.name packages) {
      text = ''
        ${builtins.readFile "${pkgs.signal-desktop}/share/applications/signal-desktop.desktop"}
        X-GNOME-Autostart-enabled=true
      '';
    };
  };
}
