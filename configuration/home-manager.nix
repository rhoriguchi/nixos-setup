{
  imports = [
    (let
      commit = "46a69810cb95d2e7286089830dc535d6719eaa6f";
      sha256 = "0ahchjycfknlxpiq3sw9l24239146llr5m2653k8330x542hwsq8";
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
