{ pkgs, config, ... }:
let home = config.users.users.rhoriguchi.home;
in {
  imports = [
    <home-manager/nixos>

    #TODO done use package source, get from github directly
    #(import "${
    #    builtins.fetchGit {
    #      ref = "release-${config.system.stateVersion}";
    #      url = "https://github.com/rycee/home-manager";
    #    }
    #  }/nixos")

    #(import "${
    #    pkgs.fetchFromGitHub {
    #      owner = "nix-community";
    #      rev = "release-${config.system.stateVersion}";
    #      sha256 = "0iksjch94wfvyq0cgwv5wq52j0dc9cavm68wka3pahhdvjlxd3js";
    #    }
    #  }/nixos")

    ./dotfiles
    ./settings.nix
    ./theme
  ];

  # TODO make firefox default browser https://askubuntu.com/questions/16621/how-to-set-the-default-browser-from-the-command-line
}
