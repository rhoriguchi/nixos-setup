{
  programs.less.enable = true;

  # TODO figure out how to use hex colors variable
  home.sessionVariables = {
    LESS_TERMCAP_so = "$(echo -e '\\x1b[38;5;127m')";
    LESS_TERMCAP_se = "$(echo -e '\\e[0m')";
  };
}
