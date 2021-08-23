{
  imports = [
    (let
      commit = "f6d1cad6ba228b81bf7045f1124aa99dfdcf3daa";
      sha256 = "0s8nlgrf16bz2bhnk0xrzvivagq55cifxf2p545c7n4zj9ryfkkp";
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
