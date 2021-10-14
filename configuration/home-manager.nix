{
  imports = [
    (let
      commit = "13e00b70a42959835190576a80fe9d8ebab062f2";
      sha256 = "1ymqnrr5p0xc9jll9sr161q5p9v1jzqkn2wnygqf6313x0vn2pds";
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
