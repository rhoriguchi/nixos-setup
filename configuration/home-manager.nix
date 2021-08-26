{
  imports = [
    (let
      commit = "f637e145d758ab183d3dba096c9312eae8bc0c7c";
      sha256 = "031iascpzdpm8ps38lc24a5vjbmdfv8xv3ds589hw9n8jrzh8idp";
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
