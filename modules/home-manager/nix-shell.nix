{
  programs.nix-your-shell = {
    enable = true;

    enableFishIntegration = true;
    enableNushellIntegration = true;
    enableZshIntegration = true;

    nix-output-monitor.enable = true;
  };
}
