{
  imports = [
    (let
      commit = "cb9f03d519cf96fcd7dfb990cc0e586a62ca6e69";
      sha256 = "1xh6ahjapms99mgxldrfwl5m28mcl022dzm3z8mjmk4qjmkkrsw4";
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
