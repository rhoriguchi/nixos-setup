{
  imports = [
    (let
      commit = "9ed7a73ae23f0d905bd098c6ce71c50289d37928";
      sha256 = "132fj7az674awk8c923if5l7ixyv260jvw4s4fw3ng1hcq4d3zb4";
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
