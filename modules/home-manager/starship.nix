{ lib, colors, ... }: {
  programs.starship = {
    enable = true;

    settings = {
      add_newline = false;
      scan_timeout = 10;

      format = lib.concatStrings [ "$nix_shell" "$directory" "$git_state" "$git_branch" "$git_status" "$character" ];

      nix_shell = {
        disabled = false;

        format = "[\\[nix-shell\\]]($style) ";
        style = "${colors.normal.green} bold";
      };

      directory = {
        format = "[$path]($style) ";
        style = "${colors.normal.accent} bold";

        truncate_to_repo = false;
        truncation_length = 999;
      };

      git_state.style = "${colors.normal.green} bold";

      git_branch.style = "${colors.normal.accent} bold";

      git_status = {
        disabled = false;

        format = "[$ahead_behind]($style)";
        style = "${colors.normal.red} bold";

        ahead = "⇡$count ";
        behind = "⇣$count ";
        diverged = "⇡$ahead_count ⇣$behind_count ";
      };

      character = {
        success_symbol = "[❯](${colors.normal.white} bold)";
        error_symbol = "[❯](${colors.normal.white} bold)";
      };
    };
  };
}
