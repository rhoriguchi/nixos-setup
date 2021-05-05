{
  imports = [
    (let
      commit = "64c5228c0828fff0c94c1d42f7225115c299ae08";
      sha256 = "06ljavkj3k5admvjf0x4ivxjmp5xmayc2gc0xq463k7qb3w27j7h";
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

    users.rhoriguchi = {
      news.display = "silent";

      manual = {
        html.enable = false;
        json.enable = false;
      };
    };
  };
}
