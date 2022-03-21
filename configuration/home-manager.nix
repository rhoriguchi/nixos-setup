{
  imports = [
    (let
      commit = "835797f3a4a59459a316ae8d4ab91fa59faf61a4";
      sha256 = "0kkfs0jdm42r4a7jhb312qppchi8wk6vgh565cqyf079kvgih0il";
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
