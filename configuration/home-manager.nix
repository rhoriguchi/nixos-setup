{
  imports = [
    (let
      commit = "afe96e7433c513bf82375d41473c57d1f66b4e68";
      sha256 = "0z6ak8mwx2n5fwqvygjlmxg20xmx6c6ffda219y3agf8gz22lfjq";
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
