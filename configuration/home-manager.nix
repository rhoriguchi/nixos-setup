{
  imports = [
    (let
      commit = "2f6d5c90f4497dc3cfc043c0fd1b77272ebaeeaa";
      sha256 = "08ck7yhcbj7129d5wdafksfn3iw0dxnrhbvyms1lvafwp585kjqg";
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
