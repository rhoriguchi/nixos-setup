{ colors, ... }:
{
  programs.jqp = {
    enable = true;

    settings.theme = {
      styleOverrides = {
        primary = colors.normal.accent;
        secondary = colors.normal.white;
        inactive = colors.extra.terminal.border;
        error = colors.normal.red;
        success = colors.normal.green;
      };

      # https://github.com/alecthomas/chroma/blob/d38b87110b078027006bc34aa27a065fa22295a1/types.go#L210-L308
      chromaStyleOverrides = {
        k = colors.normal.white; # Keyword
        n = colors.normal.blue; # Name
        l = colors.normal.gray; # Literal
        s = colors.normal.green; # String
        m = colors.normal.white; # Number
        p = colors.normal.white; # Punctuation
      };
    };
  };
}
