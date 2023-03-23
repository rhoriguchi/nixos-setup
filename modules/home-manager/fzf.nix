{ colors, ... }: {
  programs.fzf = {
    enable = true;

    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;

    colors = {
      hl = colors.bright.${colors.accent};
      "hl+" = colors.normal.${colors.accent};
      info = colors.normal.green;
      prompt = colors.normal.white;
      pointer = colors.normal.${colors.accent};
    };

    historyWidgetOptions = [ "--no-multi" ];
  };
}
