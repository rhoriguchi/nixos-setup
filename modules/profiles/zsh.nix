{ pkgs, ... }: {
  programs.zsh.enable = true;

  users.defaultUserShell = pkgs.zsh;

  environment.shellAliases = {
    l = null;
    ll = null;
    run-help = null;
    which-command = null;
  };
}
