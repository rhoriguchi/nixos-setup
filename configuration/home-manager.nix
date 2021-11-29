{
  imports = [
    (let
      commit = "9de77227d7780518cfeaee5a917970247f3ecc56";
      sha256 = "0d9mddbndy6f7q3vmfmc563ncbi407l2v1i4f9ydqlm334qzfqb9";
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
