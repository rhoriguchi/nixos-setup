{
  imports = [
    ./alacritty.nix
    ./aliases.nix
    ./autostart.nix
    ./bat.nix
    ./conky.nix
    ./firefox.nix
    ./flameshot.nix
    ./gedit.nix
    ./git.nix
    ./gnome
    ./gnome-text-editor.nix
    ./htop.nix
    ./nautilus.nix
    ./neofetch
    ./onedrive.nix
    ./ssh.nix
    ./virt-manager.nix
    ./vscode.nix
    ./zsh.nix
  ];

  home = {
    # TODO needed?
    # username = user;
    # homeDirectory = config.users.users.${user}.home;
    stateVersion = "22.11";
  };

  news.display = "silent";

  manual = {
    html.enable = false;
    json.enable = false;
  };
}
