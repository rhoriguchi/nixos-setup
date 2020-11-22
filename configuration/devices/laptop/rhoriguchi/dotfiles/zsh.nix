{ pkgs, ... }:
# TODO hand this over as variable
let username = "rhoriguchi";
in {
  home-manager.users."${username}".programs.zsh = {
    enable = true;

    shellAliases = {
      neofetch = "echo; echo; neofetch";

      # TODO only add if nautilius on path
      open = "nautilus $PWD";
    };

    enableCompletion = true;

    history = {
      size = 10000;
      extended = true;
    };

    plugins = [{
      name = pkgs.zsh-git-prompt.pname;
      file = "zshrc.sh";
      src = "${pkgs.zsh-git-prompt}/share/zsh-git-prompt";
    }];

    initExtra = ''
      autoload -U colors && colors

      # Disable mail checking
      MAILCHECK=0

      # Needed to use #, ~ and ^ in regexing filenames
      setopt extended_glob

      # Report status of background jobs immediately
      setopt NOTIFY

      # Disable beeping
      setopt NOBEEP

      # Increase stack size of dirs
      DIRSTACKSIZE=20

      # Push old directory onto the directory stack automatically
      setopt AUTO_PUSHD

      # Do not push the same dir twice
      setopt PUSHD_IGNORE_DUPS

      # Enable completion of aliases
      setopt COMPLETEALIASES

      # No matching for dotfiles (e.g. * does not expand to .dotfiles but .* does)
      setopt NOGLOBDOTS

      # Use completion
      autoload -Uz compinit

      # Enable completion from within a word
      setopt COMPLETE_IN_WORD

      # Move cursor to the end on completing a word
      setopt ALWAYS_TO_END

      # Make sure entire command is hashed before completion
      setopt HASH_LIST_ALL

      zstyle ':completion:*' auto-description 'specify: %d'
      zstyle ':completion:*' completer _expand _complete _correct _approximate
      zstyle ':completion:*' format 'Completing %d'
      zstyle ':completion:*' group-name '''
      zstyle ':completion:*' menu select=2
      eval "$(dircolors -b)"
      zstyle ':completion:*:default' list-colors ''${(s.:.)LS_COLORS}
      zstyle ':completion:*' list-colors '''
      zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
      zstyle ':completion:*' matcher-list ''' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
      zstyle ':completion:*' menu select=long
      zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
      zstyle ':completion:*' use-compctl false
      zstyle ':completion:*' verbose true

      zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
      zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'
    '';

    localVariables = {
      current_user = "%{$fg[magenta]%}$USER%{$reset_color%}";
      root = "%{$fg[red]%}root%{$reset_color%}";
      user_string = "%(!.\${root}.\${current_user})";

      hostname = "%{$fg[magenta]%}%M%{$reset_color%}";
      path_string = "%{$fg[green]%}%~%{$reset_color%}";
      prompt_string = ">";

      # TODO does not work
      PROMPT =
        "\${user_string}@\${hostname} \${path_string} \${prompt_string} %{$reset_color%}";

      # TODO perl issues
      # RPROMPT = "$(git_super_status)";
    };
  };
}
