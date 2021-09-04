{
  imports = [
    (let
      commit = "21a2ff449620a9cb91802f9d1a9157b2ae8c6b39";
      sha256 = "0q6q1i06cvksvk76ij5570nasa0wasp8qx7hxqwgi3h534kk5pnz";
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
