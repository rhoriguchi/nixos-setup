{ pkgs, ... }:
{
  # TODO replace with https://github.com/nix-community/home-manager/pull/8530 when merged
  home.packages = [ pkgs.diffnav ];

  programs.git.iniContent.pager.diff = "diffnav";

  xdg.configFile."diffnav/config.yml".source = (pkgs.formats.yaml { }).generate "config.yaml" {
    ui.icons = "nerd-fonts-filetype";
  };
}
