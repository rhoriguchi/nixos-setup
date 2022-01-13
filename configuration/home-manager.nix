{
  imports = [
    (let
      commit = "d07df8d9a80a4a34ea881bee7860ae437c5d44a5";
      sha256 = "15jqh8jqbvrwardwi62bs7r9myppc90qkzbbp7mzzsjmfgbd35i0";
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
