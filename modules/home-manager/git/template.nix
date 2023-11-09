{ pkgs, config, ... }: {
  programs.git.extraConfig.init.templatedir = "${config.home.homeDirectory}/.git_template";

  home.file.".git_template/hooks/commit-msg".source = pkgs.writeShellScript "commit-msg" ''
    readonly COMMIT_MSG_FILE="$1"

    function check_commit_msg_length {
        readonly MAX_MSG_LENGTH=72

        local title=$(head -n 1 "$COMMIT_MSG_FILE")

        if [ ''${#title} -gt $MAX_MSG_LENGTH ]; then
            # TODO figure out how to use hex colors variable
            echo -e "\x1b[1;38;5;203mCommit title is ''${#title} characters long, must be equal or shorter than $MAX_MSG_LENGTH characters!\e[0m";
            exit 1
        fi
    }

    check_commit_msg_length
  '';
}
