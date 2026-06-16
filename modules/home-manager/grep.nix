{ config, lib, ... }:
{
  programs = {
    grep = {
      enable = true;

      # TODO figure out how to use hex colors variable
      colors.mt = "1;38;5;127";
    };

    zsh.shellAliases.grep = lib.mkIf config.programs.grep.enable "${config.programs.grep.package}/bin/grep --color=auto";
  };
}
