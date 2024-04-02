{ pkgs, ... }: {
  programs.zsh = {
    enable = true;

    enableCompletion = true;

    syntaxHighlighting.enable = true;

    autosuggestion.enable = true;

    history = {
      size = 10 * 1000;
      extended = true;
      ignoreAllDups = true;
    };

    plugins = [{
      name = pkgs.zsh-nix-shell.pname;
      file = "nix-shell.plugin.zsh";
      src = "${pkgs.zsh-nix-shell}/share/${pkgs.zsh-nix-shell.pname}";
    }];

    localVariables.ZSH_AUTOSUGGEST_STRATEGY = "completion";

    sessionVariables = {
      DIRSTACKSIZE = "20";
      MAILCHECK = "0";
    };

    initExtraFirst = ''
      # Remove default alias
      unalias run-help
      unalias which-command
    '';

    initExtra = ''
      # https://zsh.sourceforge.io/Doc/Release/Options.html

      # Treat the '#', '~' and '^' characters as part of patterns for filename generation, etc. (An initial unquoted '~' always produces
      #  named directory expansion.)
      setopt EXTENDED_GLOB

      # Report the status of background jobs immediately, rather than waiting until just before printing a prompt.
      setopt NOTIFY

      # Beep on error in ZLE.
      unsetopt BEEP

      # Beep on an ambiguous completion. More accurately, this forces the completion widgets to return status 1 on an ambiguous completion
      #  which causes the shell to beep if the option BEEP is also set; this may be modified if completion is called from a user-defined
      #  widget.
      unsetopt LIST_BEEP

      # Make cd push the old directory onto the directory stack.
      setopt AUTO_PUSHD

      # Do not print the directory stack after pushd or popd.
      setopt PUSHD_SILENT

      # Don't push multiple copies of the same directory onto the directory stack.
      setopt PUSHD_IGNORE_DUPS

      # Prevents aliases on the command line from being internally substituted before completion is attempted. The effect is to make the
      #  alias a distinct command for completion purposes.
      setopt COMPLETE_ALIASES

      # Do not require a leading '.' in a filename to be matched explicitly.
      unsetopt GLOB_DOTS

      # If unset, the cursor is set to the end of the word if completion is started. Otherwise it stays there and completion is done from
      #  both ends.
      setopt COMPLETE_IN_WORD

      # If a completion is performed with the cursor within a word, and a full completion is inserted, the cursor is moved to the end of
      #  the word. That is, the cursor is moved to the end of the word if either a single match is inserted or menu completion is
      #  performed.
      setopt ALWAYS_TO_END

      # Whenever a command completion or spelling correction is attempted, make sure the entire command path is hashed first. This makes
      #  the first completion slower but avoids false reports of spelling errors.
      setopt HASH_LIST_ALL
    '';
  };
}
