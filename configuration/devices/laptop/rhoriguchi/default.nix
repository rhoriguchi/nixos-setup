{ config, ... }:
let home = config.users.users.rhoriguchi.home;
in {
  imports = [
    ./accounts-service
    ./alacritty.nix
    # TODO does not work
    # ./auto-start.nix
    ./flameshot.nix
    ./git
    ./gnome
    ./neofetch
    ./ssh
    ./vscode.nix
    ./zsh.nix
  ];
}
