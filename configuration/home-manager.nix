{
  imports = [
    (let
      commit = "7df6656b113ce0d39c8b7d30915cafe046e1d64e";
      sha256 = "0dxiicyiw53k3gqbv2k9ajnsghq1a8ln741hx5msa45zdg1r6ci3";
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
