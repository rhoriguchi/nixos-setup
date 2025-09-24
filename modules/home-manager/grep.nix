{ config, ... }:
{
  programs = {
    grep = {
      enable = true;

      # TODO figure out how to use hex colors variable
      colors.mt = "1;38;5;127";
    };

    zsh.shellAliases.grep = "${config.programs.grep.package}/bin/grep --color=auto";
  };
}
