{ colors, config, lib, pkgs, ... }: {
  # TODO uncomment when https://github.com/ajeetdsouza/zoxide/issues/618 fixed
  # currently overrides all options set here
  # https://github.com/ajeetdsouza/zoxide/blob/3fe42e901e181e791e5af3ea07d7e7d7a2b915c1/src/cmd/query.rs#L92-L118
  # home.sessionVariables._ZO_FZF_OPTS = "--bind=tab:accept";

  programs = {
    fzf = {
      enable = true;

      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;

      colors = {
        hl = colors.bright.accent;
        "hl+" = colors.normal.accent;
        info = colors.normal.green;
        prompt = colors.normal.white;
        pointer = colors.normal.accent;
        border = colors.extra.tmux.statusBackground;
        preview-border = colors.extra.tmux.statusBackground;
      };

      historyWidgetOptions = [ "--no-multi" ];
      changeDirWidgetCommand = "";
      fileWidgetCommand = "";
    };

    zsh = {
      plugins = [{
        name = pkgs.zsh-fzf-tab.pname;
        file = "fzf-tab.plugin.zsh";
        src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
      }];

      initExtra = ''
        # Use FZF_DEFAULT_OPTS
        zstyle ':fzf-tab:*' use-fzf-default-opts yes

        # Set extra options
        zstyle ':fzf-tab:*' fzf-flags --bind=tab:accept --height=25%

        # Force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
        zstyle ':completion:*' menu no

        # Preview directory's content when completing cd
        zstyle ':fzf-tab:complete:cd:*' fzf-preview '${
          if config.programs.lsd.enable then "${pkgs.lsd}/bin/lsd --color always" else "${pkgs.coreutils}/bin/ls --color=always"
        } --almost-all $realpath'

        ${lib.optionalString config.programs.zoxide.enable ''
          # Preview directory's content when completing zoxide
          zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview '${
            if config.programs.lsd.enable then "${pkgs.lsd}/bin/lsd --color always" else "${pkgs.coreutils}/bin/ls --color=always"
          } --almost-all $realpath'
        ''}
      '';
    };
  };
}
