{
  imports = [
    (let
      commit = "7e2b1a42aaf709bb982dd1dad6f1f3bba290d64d";
      sha256 = "17pqmhwd2vwj9ib7cyq9cf3wfzfibkkkq3dfviss5dmlacdwjb19";
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
