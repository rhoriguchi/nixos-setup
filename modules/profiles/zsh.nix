{ pkgs, ... }: {
  programs.zsh.enable = true;

  users.defaultUserShell = pkgs.zsh;

  environment.shellAliases = {
    run-help = null;
    which-command = null;
  };
}
