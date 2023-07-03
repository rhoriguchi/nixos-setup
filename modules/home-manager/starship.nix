{ lib, colors, ... }: {
  programs.starship = {
    enable = true;

    settings = {
      add_newline = false;
      scan_timeout = 10;

      format = lib.concatStrings [ "$directory" "$git_branch" "$character" ];

      directory = {
        format = "[$path]($style) ";
        style = "${colors.normal.accent} bold";

        truncate_to_repo = false;
        truncation_length = 999;
      };

      git_branch.style = "${colors.normal.accent} bold";

      character = {
        success_symbol = "[❯](white bold)";
        error_symbol = "[❯](white bold)";
      };
    };
  };
}
