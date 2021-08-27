{
  imports = [
    (let
      commit = "33db7cc6a66d1c1cb77c23ae8e18cefd0425a0c8";
      sha256 = "0c389qdjjz5a3afyy06q09gal22hi46s0w07dd9d7bpvpfsnk6dp";
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
