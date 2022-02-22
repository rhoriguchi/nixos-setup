{
  imports = [
    (let
      commit = "838d40d61a91e3807836545c4b420572ab2d62eb";
      sha256 = "1a6mnchmv27sz9fs65m0zglhmsbplnfx8isqjf91n7xw4c8q1w7c";
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
