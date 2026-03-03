{ pkgs, ... }:
{
  services.hyprpaper = {
    enable = true;

    settings.wallpaper = [
      {
        monitor = "";
        path = "${pkgs.wallpaper}/share/icons/hicolor/3840x2160/apps/wallpaper.jpg";
      }
    ];
  };
}
