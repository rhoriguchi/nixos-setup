{ colors, config, lib, pkgs, ... }: {
  programs = {
    fzf = {
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
        border = colors.extra.tmux.statusBackground;
        preview-border = colors.extra.tmux.statusBackground;
      };

      historyWidgetOptions = [ "--no-multi" ];
      changeDirWidgetCommand = "";
      fileWidgetCommand = "";
    };

    zsh = {
      plugins = [{
        name = pkgs.zsh-fzf-tab.pname;
        file = "fzf-tab.plugin.zsh";
        src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
      }];

      initExtra = ''
        # Use FZF_DEFAULT_OPTS
        zstyle ':fzf-tab:*' use-fzf-default-opts yes

        # Set extra options
        zstyle ':fzf-tab:*' fzf-flags --bind=tab:accept

        # Force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
        zstyle ':completion:*' menu no

        # Preview directory's content when completing cd
        zstyle ':fzf-tab:complete:cd:*' fzf-preview '${
          if config.programs.lsd.enable then "${pkgs.lsd}/bin/lsd" else "ls"
        } --almost-all --color always $realpath'

        ${lib.optionalString config.programs.zoxide.enable ''
          # Preview directory's content when completing zoxide
          zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview '${
            if config.programs.lsd.enable then "${pkgs.lsd}/bin/lsd" else "ls"
          } --almost-all --color always $realpath'
        ''}
      '';
    };
  };
}
