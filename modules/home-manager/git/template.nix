{ pkgs, config, ... }: {
  programs.git.extraConfig.init.templatedir = "${config.home.homeDirectory}/.git_template";

  home.file = {
    ".git_template/hooks/commit-msg".source = pkgs.writers.writeBash "commit-msg" ''
      readonly COMMIT_MSG_FILE="$1"

      function check_commit_msg_length {
          readonly MAX_TITLE_LENGTH=72

          local title=$(${pkgs.coreutils}/bin/head -n 1 "$COMMIT_MSG_FILE")

          if [ ''${#title} -gt $MAX_TITLE_LENGTH ]; then
              # TODO figure out how to use hex colors variable
              echo -e "\x1b[1;38;5;203mCommit title is ''${#title} characters long, must be equal or shorter than $MAX_TITLE_LENGTH characters!\e[0m";
              exit 1
          fi
      }

      check_commit_msg_length
    '';

    ".git_template/hooks/post-checkout".source = pkgs.writers.writeBash "post-checkout" ''
      readonly PREV_HEAD="$1"
      readonly NEW_HEAD="$2"
      # Retrieving a file from the index, flag=0 / changing branches, flag=1
      readonly CHECKOUT_TYPE="$3"

      function alias_main {
        local current_branch="$(${pkgs.coreutils}/bin/cut -d ' ' -f2 "$(git rev-parse --show-toplevel)/.git/HEAD" | ${pkgs.gnused}/bin/sed 's|refs/heads/||')"

        if [ "$current_branch" = "main" ]; then
          git symbolic-ref refs/heads/master refs/heads/main
          git switch master
        fi
      }

      if [ "$CHECKOUT_TYPE" = "1" ]; then
        alias_main
      fi
    '';
  };
}
