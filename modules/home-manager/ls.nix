{
  programs.lsd = {
    enable = true;

    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;

    settings = {
      icons.when = "never";
      symlink-arrow = "->";
    };
  };
}
