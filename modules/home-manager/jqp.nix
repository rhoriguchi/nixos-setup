{ colors, pkgs, ... }: {
  home = {
    packages = [
      pkgs.jqp

      # needed for copy
      pkgs.wl-clipboard
    ];

    file.".jqp.yaml".source = (pkgs.formats.yaml { }).generate ".jqp.yaml" {
      theme = {
        styleOverrides = {
          primary = colors.normal.accent;
          secondary = colors.normal.white;
          inactive = colors.extra.tmux.statusBackground;
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
  };
}
