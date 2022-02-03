{
  imports = [
    (let
      commit = "9d369c75ce2fdeb296ad42bcdc8c1a523c494550";
      sha256 = "0y2w9kfpxgildb6kjsr60xdxb6b9914h37gxnrf3g6shqiwgjvw9";
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
  };
}
