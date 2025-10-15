{ pkgs, ... }:
{
  services.hyprpaper = {
    enable = true;

    settings = {
      preload = [ "${pkgs.wallpaper}/share/icons/hicolor/3840x2160/apps/wallpaper.jpg" ];

      wallpaper = [ ", ${pkgs.wallpaper}/share/icons/hicolor/3840x2160/apps/wallpaper.jpg" ];
    };
  };
}
