{ config, ... }:
let home = config.users.users.rhoriguchi.home;
in {
  imports = [
    ./accounts-service
    # TODO does not work
    # ./auto-start.nix
    ./dircolors
    ./flameshot.nix
    ./git
    ./gnome
    ./gnome-terminal.nix
    ./neofetch
    ./ssh
    ./vscode.nix
    ./zsh.nix
  ];
}
