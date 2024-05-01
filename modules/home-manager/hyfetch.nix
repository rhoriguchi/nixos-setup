{ config, ... }: {
  programs.zsh.shellAliases.neofetch = "${config.programs.hyfetch.package}/bin/hyfetch";

  programs.hyfetch = {
    enable = true;

    settings = {
      preset = "rainbow";
      mode = "rgb";
      light_dark = "light";
      lightness = 0.4;
      color_align = {
        mode = "horizontal";
        custom_colors = [ ];
        fore_back = null;
      };
      backend = "neofetch";
      args = null;
      distro = null;
      pride_month_shown = [ ];
      pride_month_disable = false;
    };
  };
}
