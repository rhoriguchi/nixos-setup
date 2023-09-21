{ pkgs, ... }: {
  home = {
    packages = [ pkgs.gnugrep ];

    # TODO figure out how to use hex colors variable
    sessionVariables.GREP_COLORS = "mt=1;38;5;127";
  };

  programs.zsh.shellAliases.grep = "${pkgs.gnugrep}/bin/grep --color=auto";
}
