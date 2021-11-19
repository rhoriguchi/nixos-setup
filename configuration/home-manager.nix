{
  imports = [
    (let
      commit = "2452979efe92128b03e3c27567267066c2825fab";
      sha256 = "0g3sxm407m7qfk6r2hp2jh4bp0samn9y2kcs74cspfiyhh8ss9j4";
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
