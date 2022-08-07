{
  environment.variables.EDITOR = "nano";

  programs.nano = {
    nanorc = ''
      set constantshow
      set linenumbers
      set softwrap
      set tabsize 4
      set tabstospaces
      unset nonewlines
    '';

    syntaxHighlight = true;
  };
}
