{ pkgs, colors, ... }: {
  programs = {
    fzf.tmux.enableShellIntegration = true;

    zsh.initExtra = ''
      if hash tmux 2>/dev/null && ! pgrep tmux >/dev/null; then
        if [ "$TERM_PROGRAM" != "vscode" ] && [ "$TERMINAL_EMULATOR" != "JetBrains-JediTerm" ]; then
          tmux new-session -n ""
        fi
      fi
    '';

    tmux = {
      enable = true;

      shortcut = "a";
      keyMode = "emacs";
      mouse = true;
      clock24 = true;
      historyLimit = 10000;
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
