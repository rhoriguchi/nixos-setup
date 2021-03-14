{ ... }: {
  imports = [
    # TODO use url?
    <home-manager/nixos>

    ./accounts-service
    ./alacritty.nix
    ./flameshot.nix
    ./fzf.nix
    ./git
    ./gnome
    ./htop
    ./neofetch
    ./ssh.nix
    ./vscode.nix
    ./zsh.nix
  ];
}
