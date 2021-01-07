{ pkgs, config, ... }:
let home = config.users.users.rhoriguchi.home;
in {
  imports = [
    ./auto-start.nix
    ./dconf
    ./dircolors
    ./flameshot.nix
    ./git
    ./gnome-terminal.nix
    ./neofetch
    ./ssh
    ./vscode.nix
    ./zsh.nix
  ];

  # TODO make eog default image viewer
  # TODO make firefox default browser https://askubuntu.com/questions/16621/how-to-set-the-default-browser-from-the-command-line
}
