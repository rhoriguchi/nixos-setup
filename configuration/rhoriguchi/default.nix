{ config, ... }: {
  imports = [
    (let
      commit = "70d5929885ccec8dde8585894dd3ebe606e75f41";
      sha256 = "1n03v5p8822hmx94sn31w16a11grx8f6dj2rnl8qccgxmssi5alx";
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
