{
  imports = [
    (let
      commit = "6d9d9294d09b5e88df65f8c6651efb8a4d7d2476";
      sha256 = "08ksdh2bfagxxn8vh540wkfa64547vswrr55lz9zpmn5mwkgydqv";
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
