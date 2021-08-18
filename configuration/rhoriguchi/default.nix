{
  imports = [
    ../home-manager.nix

    ./accounts-service
    ./alacritty.nix
    ./autostart.nix
    ./docker.nix
    ./firefox
    ./flameshot.nix
    ./fzf.nix
    ./git.nix
    ./gnome
    ./htop.nix
    ./neofetch
    ./onedrive.nix
    ./ssh.nix
    ./vscode.nix
    ./zsh.nix
  ];

  home-manager.users.rhoriguchi = {
    news.display = "silent";

    manual = {
      html.enable = false;
      json.enable = false;
    };
  };
}
