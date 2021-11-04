{
  imports = [
    (let
      commit = "70c5b268e10025c70823767f4fb49e240b40151d";
      sha256 = "09si7wq89qpyzfxgs1862s7lv8sl0ikwx7cy9vavf1hd5y6m13s4";
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
