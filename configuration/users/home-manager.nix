{
  imports = [
    (let
      commit = "cc60c22c69e6967b732d02f072a9f1e30454e4f6";
      sha256 = "191w8ps6m8kf2fxdbmcsa75j5bbirrvgb2cavrj69dkhsll9czh7";
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
