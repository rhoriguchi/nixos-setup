{
  imports = [
    (let
      commit = "64607f58b75741470284c698f82f0199fcecdfa7";
      sha256 = "11mi34z030favcp3kizkwdxpbfzk9if25iw0y5dknrx4q965ijjd";
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
