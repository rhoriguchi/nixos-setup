{
  imports = [
    (let
      commit = "48f2b381dd397ec88040d3354ac9c036739ba139";
      sha256 = "1i9v94brh9vhyhzcqyfj64nzhaibdj0sw74pxgk4bcsp0hqawgcd";
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
