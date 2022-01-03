{
  imports = [
    (let
      commit = "8e7a10602d1eb1d242c9d3f9b822203d5751a8c6";
      sha256 = "01i3x7lnzr1dz77djdl4lizg251v4fx9hpfcim3h2hjc2crqxxmj";
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
