{ config, ... }:
let home = config.users.users.rhoriguchi.home;
in {
  imports = [
    ./accounts-service
    ./alacritty.nix
    # TODO does not work
    # ./auto-start.nix
    ./flameshot.nix
    ./fzf.nix
    ./git
    ./gnome
    ./htop
    ./neofetch
    ./ssh
    ./vscode.nix
    ./zsh.nix
  ];
}
