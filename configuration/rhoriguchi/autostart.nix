{ pkgs, lib, config, ... }:
let packageNames = lib.unique (map (package: package.name) (config.environment.systemPackages ++ config.users.users.rhoriguchi.packages));
in {
  home-manager.users.rhoriguchi.xdg.configFile = {
    "autostart/${pkgs.discord.pname}.desktop".source =
      lib.mkIf (lib.elem pkgs.discord.name packageNames) "${pkgs.discord}/share/applications/discord.desktop";

    "autostart/${pkgs.flameshot.pname}.desktop".text = let
      content = lib.readFile "${pkgs.flameshot}/share/applications/org.flameshot.Flameshot.desktop";
      fixedContent = builtins.replaceStrings [ "/usr/bin/flameshot" ] [ "flameshot" ] content;
    in lib.mkIf (lib.elem pkgs.flameshot.name packageNames) fixedContent;

    "autostart/${pkgs.protonvpn-gui.pname}.desktop".source =
      lib.mkIf (lib.elem pkgs.protonvpn-gui.name packageNames) "${pkgs.protonvpn-gui}/share/applications/protonvpn-tray.desktop";

    "autostart/${pkgs.signal-desktop.pname}.desktop".source =
      lib.mkIf (lib.elem pkgs.signal-desktop.name packageNames) "${pkgs.signal-desktop}/share/applications/signal-desktop.desktop";
  };
}
