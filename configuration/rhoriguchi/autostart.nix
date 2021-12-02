{ pkgs, lib, config, ... }:
let packageNames = lib.unique (map (package: package.name) (config.environment.systemPackages ++ config.users.users.rhoriguchi.packages));
in {
  home-manager.users.rhoriguchi.xdg.configFile = {
    "autostart/${pkgs.discord.pname}.desktop" =
      lib.mkIf (lib.elem pkgs.discord.name packageNames) { source = "${pkgs.discord}/share/applications/discord.desktop"; };

    "autostart/${pkgs.flameshot.pname}.desktop" = lib.mkIf (lib.elem pkgs.flameshot.name packageNames) {
      text = let content = lib.readFile "${pkgs.flameshot}/share/applications/org.flameshot.Flameshot.desktop";
      in builtins.replaceStrings [ "/usr/bin/flameshot" ] [ "flameshot" ] content;
    };

    "autostart/${pkgs.solaar.pname}.desktop" =
      lib.mkIf (lib.elem pkgs.solaar.name packageNames) { source = "${pkgs.solaar}/share/applications/solaar.desktop"; };

    "autostart/${pkgs.signal-desktop.pname}.desktop" = lib.mkIf (lib.elem pkgs.signal-desktop.name packageNames) {
      source = "${pkgs.signal-desktop}/share/applications/signal-desktop.desktop";
    };
  };
}
