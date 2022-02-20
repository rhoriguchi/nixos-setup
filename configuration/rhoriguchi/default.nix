{
  imports = [
    ../home-manager.nix

    ./alacritty.nix
    ./aliases.nix
    ./autostart.nix
    ./conky.nix
    ./docker.nix
    ./firefox
    ./flameshot.nix
    ./fzf.nix
    ./git.nix
    ./gnome
    ./gnome-accounts-service
    ./htop.nix
    ./nautilus.nix
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
