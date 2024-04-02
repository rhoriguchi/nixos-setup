{ pkgs, ... }: {
  programs.zsh.enable = true;

  users.defaultUserShell = pkgs.zsh;

  environment.shellAliases = {
    l = null;
    ll = null;
    ls = null;
  };
}
