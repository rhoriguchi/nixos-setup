{
  imports = [
    (let
      commit = "1de492f6f8e9937c822333739c5d5b20d93bf49f";
      sha256 = "0awlcj827vx3za3k93676v7713wn0iyqhli87ai3z8gii1hx52nq";
    in "${
      fetchTarball {
        url = "https://github.com/nix-community/home-manager/archive/${commit}.tar.gz";
        inherit sha256;
      }
    }/nixos")

    ./alacritty.nix
    ./aliases.nix
    ./autostart.nix
    ./bat.nix
    ./conky.nix
    ./docker.nix
    ./firefox
    ./flameshot.nix
    ./fzf.nix
    ./gedit.nix
    ./git.nix
    ./gnome
    ./gnome-accounts-service
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

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.rhoriguchi = {
      news.display = "silent";

      manual = {
        html.enable = false;
        json.enable = false;
      };
    };
  };
}
