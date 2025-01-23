{ colors, config, pkgs, ... }:
let
  homeDirectory = config.home.homeDirectory;

  tmux = "${config.programs.tmux.package}/bin/tmux";
  tmuxp = "${pkgs.tmuxp}/bin/tmuxp";

  attachSession = "${tmux} has-session -t Default && ${tmux} attach-session -t Default || ${tmuxp} load Default";
in {
  programs = {
    fzf.tmux.enableShellIntegration = true;

    zsh = {
      shellAliases = {
        attach = attachSession;
        clear = "${pkgs.ncurses}/bin/clear && ${tmux} clear-history 2> /dev/null";
        detach = "${tmux} detach-client";
      };

      initExtra = ''
        if [ "$TMUX" = ''' ]; then
          if [ "$XDG_SESSION_TYPE" = 'tty' ]; then
            ${tmux} has-session -t "TTY $(basename $(tty))" && ${tmux} attach-session -t "TTY $(basename $(tty))" || ${tmux} new-session -s "TTY $(basename $(tty))"
          elif [ "$TERM_PROGRAM" != 'vscode' ] && [ "$TERMINAL_EMULATOR" != 'JetBrains-JediTerm' ]; then
            ${attachSession}
          fi
        fi
      '';
    };

    tmux = {
      enable = true;

      tmuxp.enable = true;

      shortcut = "a";
      keyMode = "emacs";
      mouse = true;
      clock24 = true;
      historyLimit = 10 * 1000;
      terminal = "screen-256color";

      extraConfig = ''
        unbind '"'
        bind v split-window

        unbind %
        bind h split-window -h

        # backwards: n | forwards: N
        bind / copy-mode \; send-key C-r

        set -g base-index 1
        set -g clock-mode-colour '${colors.normal.accent}'
        set -g message-command-style bg='${colors.normal.black}',fg='${colors.normal.green}'
        set -g message-style bg='${colors.normal.green}',fg='${colors.normal.black}'
        set -g mode-style 'fg=default,bg=default,reverse'
        set -g pane-active-border-style fg='${colors.normal.accent}'
        set -g status-bg '#3d3d3d'
        set -g status-fg '${colors.normal.accent}'
        set -g status-interval 1
        set -g status-justify 'centre'
        set -g status-left '#{?#{==:#S,Default},,[#S]}'
        set -g status-left-length 20
        set -g status-right '''
        set -g window-status-current-format ' #I:#W '
        set -g window-status-current-style bg='${colors.normal.accent}',fg='#3d3d3d'
        set -g window-status-format ' #I:#W '
        set -g window-status-separator '''
        set -g window-status-style bg='#3d3d3d',fg='${colors.normal.accent}'
      '';
    };
  };

  home.file.".tmuxp/Default.yaml".source = (pkgs.formats.yaml { }).generate "Default.yml" {
    session_name = "Default";
    start_directory = homeDirectory;

    windows = [
      {
        focus = true;
        start_directory = homeDirectory;
      }
      {
        window_name = "Nix config";
        start_directory = "${homeDirectory}/Sync/Git/nixos-setup";
        window_index = 9;
      }
    ];
  };
}
