{ pkgs, ... }: {
  home = {
    packages = [ pkgs.nano ];

    sessionVariables = {
      EDITOR = "nano";
      KUBE_EDITOR = "nano";
    };

    file.".nanorc".text = ''
      include "${pkgs.nano}/share/nano/*.nanorc"

      set constantshow
      set linenumbers
      set softwrap
      set tabsize 4
      set tabstospaces
      unset nonewlines
    '';
  };

  programs.git.extraConfig.core.editor = "nano";
}
