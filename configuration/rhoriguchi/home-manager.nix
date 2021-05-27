{
  imports = [
    (let
      commit = "b840707a87f6a35a5c24ea6edf8846741d924616";
      sha256 = "0slgmf74dcnjp6va1gi6vcxxqbag4sk6zk5w5p6rlcjs5q3d2idl";
    in "${
      fetchTarball {
        url = "https://github.com/nix-community/home-manager/archive/${commit}.tar.gz";
        inherit sha256;
      }
    }/nixos")
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
