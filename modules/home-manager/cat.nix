{ lib, pkgs, ... }: {
  programs.zsh.shellAliases.cat = "${pkgs.bat}/bin/bat";

  programs.bat = {
    enable = true;

    config = {
      paging = "never";
      style = lib.concatStringsSep "," [ "numbers" ];
      tabs = "4";
      theme = "ansi";
    };
  };
}
