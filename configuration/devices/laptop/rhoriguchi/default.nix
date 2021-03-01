{ ... }: {
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
