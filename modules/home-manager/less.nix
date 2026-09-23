{
  colors,
  libCustom,
  ...
}:
{
  programs.less.enable = true;

  home.sessionVariables = {
    LESS_TERMCAP_so = "$(echo -e '${libCustom.ansiColor colors.normal.accent { }}')";
    LESS_TERMCAP_se = ''$(echo -e '\e[0m')'';
  };
}
