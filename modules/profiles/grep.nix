{ pkgs, ... }: {
  environment = {
    systemPackages = [ pkgs.gnugrep ];

    # TODO figure out how to use hex colors variable
    sessionVariables.GREP_COLORS = "mt=1;38;5;127";

    shellAliases.grep = "grep --color=auto";
  };
}
