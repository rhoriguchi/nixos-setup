{
  imports = [
    (let
      commit = "3db603677509eb0b8c396a3234b1d4b70d023894";
      sha256 = "0cb2nknfxrfybhi6var3qgil9hx3d7s1iay80rj5y7af7dahp0yq";
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
