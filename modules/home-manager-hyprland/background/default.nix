{
  services.hyprpaper = {
    enable = true;

    settings = {
      preload = [ "${./wallpaper.jpg}" ];

      wallpaper = [ ", ${./wallpaper.jpg}" ];
    };
  };
}
