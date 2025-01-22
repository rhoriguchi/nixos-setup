{ colors, ... }: {
  programs.fzf = {
    enable = true;

    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;

    colors = {
      hl = colors.bright.accent;
      "hl+" = colors.normal.accent;
      info = colors.normal.green;
      prompt = colors.normal.white;
      pointer = colors.normal.accent;
    };

    historyWidgetOptions = [ "--no-multi" ];
    changeDirWidgetCommand = "";
    fileWidgetCommand = "";
  };
}
