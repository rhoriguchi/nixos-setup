{ config, pkgs, colors, ... }: {
  programs = {
    fzf.tmux.enableShellIntegration = true;

    zsh = {
      shellAliases = let inherit (config.programs.tmux) package;
      in {
        attach = "${package}/bin/tmux attach-session -t 'default' || ${package}/bin/tmux new-session -s 'default'";
        clear = "clear && ${package}/bin/tmux clear-history 2> /dev/null";
        detach = "${package}/bin/tmux detach-client";
      };

      initExtra = ''
        if [ "$TMUX" = ''' ]; then
          if [ "$XDG_SESSION_TYPE" = 'tty' ]; then
            tmux attach-session -t "$(basename $(tty))" || tmux new-session -s "$(basename $(tty))"
          elif [ "$TERM_PROGRAM" != 'vscode' ] && [ "$TERMINAL_EMULATOR" != 'JetBrains-JediTerm' ]; then
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

        set -g clock-mode-colour "${colors.normal.accent}"
        set -g message-command-style bg=black,fg=green
        set -g message-style bg=green,fg=black
        set -g mode-style 'reverse'
        set -g pane-active-border-style fg="${colors.normal.accent}"
        set -g status-bg "${colors.normal.accent}"
        set -g status-fg black
        set -g status-interval 1
        set -g status-right ""
      '';
    };
  };
}
