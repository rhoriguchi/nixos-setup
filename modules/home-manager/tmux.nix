{ pkgs, colors, ... }: {
  programs = {
    fzf.tmux.enableShellIntegration = true;

    zsh = {
      shellAliases.clear = "clear && tmux clear-history 2> /dev/null";

      initExtra = ''
        if [ "$TMUX" = ''' ]; then
          if [ "$TERM_PROGRAM" != 'vscode' ] && [ "$TERMINAL_EMULATOR" != 'JetBrains-JediTerm' ]; then
            tmux attach-session -t 'default' || tmux new-session -s 'default'
          fi
        fi
      '';
    };

    tmux = {
      enable = true;

      shortcut = "a";
      keyMode = "emacs";
      mouse = true;
      clock24 = true;
      historyLimit = 10 * 1000;
      shell = "${pkgs.zsh}/bin/zsh";
      terminal = "screen-256color";

      extraConfig = ''
        bind h split-window -h
        unbind %

        bind v split-window
        unbind '"'

        set -g clock-mode-colour ${colors.accent}
        set -g message-command-style bg=black,fg=green
        set -g message-style bg=green,fg=black
        set -g mode-style 'reverse'
        set -g pane-active-border-style fg=${colors.accent}
        set -g status-bg ${colors.accent}
        set -g status-fg black
        set -g status-interval 1
        set -g status-right ""
      '';
    };
  };
}
