{ pkgs, lib, ... }: {
  home.packages = [ pkgs.bat ];

  programs.zsh.shellAliases.cat = "bat";

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
