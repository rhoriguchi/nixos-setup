{
  imports = [
    (let
      commit = "07b941f0c45ac4af6732d96f4cb6142824eee3df";
      sha256 = "1dnv50zyh3zvv5f6ff4xnwgh6gd00qgawgz2dw9920xmwk2r97dn";
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
