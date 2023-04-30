{ pkgs, colors, ... }: {
  programs = {
    fzf.tmux.enableShellIntegration = true;

    zsh.initExtra = ''
      if hash tmux 2>/dev/null && ! pgrep tmux >/dev/null; then
        if [ "$TERM_PROGRAM" != "vscode" ] && [ "$TERMINAL_EMULATOR" != "JetBrains-JediTerm" ]; then
          tmux new-session -n ""
          echo "Tmux session started"
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
        set -g pane-active-border-style fg=${colors.accent}
        set -g status-bg ${colors.accent}
        set -g status-fg black
        set -g status-right ""
      '';
    };
  };
}
