{
  programs.direnv = {
    enable = true;

    nix-direnv.enable = true;

    stdlib = ''
      # https://github.com/direnv/direnv/wiki/Customizing-cache-location
      : ''${XDG_CACHE_HOME:=$HOME/.cache}
      declare -A direnv_layout_dirs
      direnv_layout_dir() {
          echo "''${direnv_layout_dirs[$PWD]:=$(
              echo -n "$XDG_CACHE_HOME"/direnv/layouts/
              echo -n "$PWD" | sha1sum | cut -d ' ' -f 1
          )}"
      }
    '';
  };
}
