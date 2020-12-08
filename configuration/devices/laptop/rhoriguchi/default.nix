{ pkgs, config, ... }: {
  imports = [
    # TODO done use package source, get from github directly
    <home-manager/nixos>

    # (import "${
    #     builtins.fetchGit {
    #       ref = "release-${config.system.stateVersion}";
    #       url = "https://github.com/rycee/home-manager";
    #     }
    #   }/nixos")

    # (import "${
    #     pkgs.fetchFromGitHub {
    #       owner = "nix-community";
    #       rev = "release-${config.system.stateVersion}";
    #       sha256 = "0iksjch94wfvyq0cgwv5wq52j0dc9cavm68wka3pahhdvjlxd3js";
    #     }
    #   }/nixos")

    ./dotfiles
    ./settings.nix
    ./theme
  ];

  users.users.rhoriguchi = {
    extraGroups = [ "docker" "networkmanager" "rslsync" "vboxusers" "wheel" ];
    home = "/home/rhoriguchi";
    isNormalUser = true;
  };

  home-manager.users.rhoriguchi.home = {
    language = {
      base = "en_US.UTF-8";
      numeric = "de_CH.UTF-8";
      time = "de_CH.UTF-8";
      collate = "en_US.UTF-8";
      monetary = "de_CH.UTF-8";
      messages = "en_US.UTF-8";
      paper = "de_CH.UTF-8";
      measurement = "de_CH.UTF-8";
    };

    keyboard.layout = "ch";
  };

  # TODO set up gnome calendar
  # TODO make firefox default browser https://askubuntu.com/questions/16621/how-to-set-the-default-browser-from-the-command-line
}
