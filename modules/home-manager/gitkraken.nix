{
  config,
  lib,
  pkgs,
  ...
}:
{
  home.packages = lib.mkIf config.programs.nixkraken.enable [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.roboto-mono
  ];

  programs.nixkraken = {
    enable = true;

    acceptEULA = true;
    skipTutorial = true;

    git.defaultBranch = config.programs.git.settings.init.defaultBranch;

    notifications = {
      feature = false;
      help = false;
      marketing = false;
    };

    # TODO remove when fixed upstream
    # Defaults of `user.*` read the removed `programs.git.userEmail`/`userName`
    # and throw; the root `user` is only used by the skipTutorial assertions,
    # every profile has its own `user` that needs to be overridden too.
    user = {
      email = config.programs.git.settings.user.email;
      name = config.programs.git.settings.user.name;
    };

    profiles = [
      {
        name = "Default";
        isDefault = true;

        # TODO remove when fixed upstream
        user = config.programs.nixkraken.user;

        ui = {
          cli.fontFamily = "RobotoMono Nerd Font";
          editor.fontFamily = "JetBrainsMono Nerd Font";
        };
      }
    ];
  };
}
