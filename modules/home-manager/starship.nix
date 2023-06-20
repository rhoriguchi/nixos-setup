{ lib, colors, ... }:
let accentColor = if colors.accent == "magenta" then "purple" else colors.accent;
in {
  programs.starship = {
    enable = true;

    settings = {
      add_newline = false;
      scan_timeout = 10;

      format = lib.concatStrings [ "$directory" "$git_branch" "$character" ];

      directory = {
        format = "[$path]($style) ";
        style = "${accentColor} bold";

        truncate_to_repo = false;
        truncation_length = 999;
      };

      character = {
        success_symbol = "[❯](white bold)";
        error_symbol = "[❯](white bold)";
      };
    };
  };
}
