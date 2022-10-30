{ pkgs, ... }: {
  environment = {
    systemPackages = [ pkgs.alacritty ];

    variables.TERMINAL = "alacritty";
  };
}
