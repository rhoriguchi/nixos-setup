{ pkgs, ... }: {
  environment = {
    systemPackages = [ pkgs.alacritty ];

    variables.TERMINAL = "alacritty";
  };

  programs.zsh.enable = true;

  users.defaultUserShell = pkgs.zsh;

  environment.shellAliases = {
    l = null;
    ll = null;
  };
}
