{ pkgs, ... }: {
  environment = {
    systemPackages = [ pkgs.alacritty ];

    variables.TERMINAL = "alacritty";

    gnome.excludePackages = [ pkgs.gnome-console ];
  };
}
