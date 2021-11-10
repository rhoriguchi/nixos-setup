{
  imports = [
    (let
      commit = "1e5c8e9bff00d0844bc3d25d1a98eab5633e600b";
      sha256 = "00i9q8spjhg6hk42imf9xwarbkmaxs8ahavydgia06qhw3rr0640";
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
