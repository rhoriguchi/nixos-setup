{ pkgs, ... }: {
  programs.direnv = {
    enable = true;

    enableBashIntegration = true;
    enableFishIntegration = true;
    enableNushellIntegration = true;
    enableZshIntegration = true;

    silent = true;
    nix-direnv.enable = true;

    stdlib = ''
      # https://github.com/direnv/direnv/wiki/Customizing-cache-location
      : ''${XDG_CACHE_HOME:=$HOME/.cache}
      declare -A direnv_layout_dirs
      direnv_layout_dir() {
        echo "''${direnv_layout_dirs[$PWD]:=$(
          echo -n "$XDG_CACHE_HOME"/direnv/layouts/
          echo -n "$PWD" | ${pkgs.coreutils}/bin/sha1sum | ${pkgs.coreutils}/bin/cut -d ' ' -f 1
        )}"
      }
    '';
  };
}
