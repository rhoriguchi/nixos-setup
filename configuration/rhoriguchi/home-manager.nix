{
  imports = [
    (let
      commit = "3b799f6ea42f850316ae4741ff323dc74ce09467";
      sha256 = "04fh08jk97h90asx1x3g7l8lkcqzax4s8w9g13criaryyc2ybvsi";
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
