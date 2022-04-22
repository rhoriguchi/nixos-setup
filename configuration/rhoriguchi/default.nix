{
  imports = [
    (let
      commit = "93a69d07389311ffd6ce1f4d01836bbc2faec644";
      sha256 = "0z1jzn1923g2q376z4268b4cdif96i7l6lm7bd06z19qqgciqkyz";
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
