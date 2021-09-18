{
  imports = [
    (let
      commit = "371576cdc2580ba93a38e28da8ece2129f558815";
      sha256 = "0vwkmnvc4pggicgzii4gg22pv5whp2aiian0rs80srwzkxl2sz0n";
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
