{
  imports = [
    (let
      commit = "acf824c9ed70f623b424c2ca41d0f6821014c67c";
      sha256 = "0j803rihz0jj14icc8wlmnm57mmzfpfvjg65gn6y2cdmc9df6m5b";
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
