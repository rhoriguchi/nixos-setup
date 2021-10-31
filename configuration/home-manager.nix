{
  imports = [
    (let
      commit = "275f955db979e069fbe7a1fd7cfcb5ec030a2096";
      sha256 = "1zjspmxyp4h75z1f51imnzdv54lnjqafdpisinf48bzd1mxlcvar";
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
