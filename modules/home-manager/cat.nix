{ config, lib, ... }:
{
  programs.zsh.shellAliases.cat = lib.mkIf config.programs.bat.enable "${config.programs.bat.package}/bin/bat";

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
