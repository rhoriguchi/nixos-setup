{
  imports = [
    (let
      commit = "66d9dbfa36f59748e06bb30cd98b3f4ad76cd482";
      sha256 = "1n3rl7jh73vjpbhs0pcxjnkk6fpvqllbinlz5zjx9y1wv2vmfial";
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
