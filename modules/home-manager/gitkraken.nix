{
  config,
  pkgs,
  ...
}:
{
  home.packages = [
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

    profiles = [
      {
        name = "Default";
        isDefault = true;

        ui = {
          cli.fontFamily = "RobotoMono Nerd Font";
          editor.fontFamily = "JetBrainsMono Nerd Font";
        };
      }
    ];
  };
}
