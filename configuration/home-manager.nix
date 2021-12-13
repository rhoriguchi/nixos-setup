{
  imports = [
    (let
      commit = "ea5591d225c379d7b0ad594ab901bec498aefe91";
      sha256 = "0rz74wb909ym3n5zj0c0nz32kdxrh4jg1yaxic3jk7m3pqvyrr44";
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
