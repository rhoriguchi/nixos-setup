{ config, ... }: {
  imports = [
    (let
      commit = "4c5106ed0f3168ff2df21b646aef67e86cbfc11c";
      sha256 = "0r6hmz68mlir68jk499yii7g2qprxdn76i3bgky6qxsy8vz78mgi";
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
      home.stateVersion = config.system.stateVersion;

      news.display = "silent";

      manual = {
        html.enable = false;
        json.enable = false;
      };
    };
  };
}
