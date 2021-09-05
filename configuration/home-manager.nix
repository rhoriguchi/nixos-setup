{
  imports = [
    (let
      commit = "2952168ed59aa369a560563de2e00eab19f42d1b";
      sha256 = "081bj9b3wwmc65gimkn6mwr40vjik6nl00gyqznfn59x6jj2nhhw";
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
