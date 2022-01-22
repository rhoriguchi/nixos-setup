{
  imports = [
    (let
      commit = "e622c5d83633c16d29c50f8d777dddf2290c0b8c";
      sha256 = "023n8f93hjkjc6cw1lxq4sjgwpimwfr5qb5xlvpza6mjsrhw2n6f";
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
