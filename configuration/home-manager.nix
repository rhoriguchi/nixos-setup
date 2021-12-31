{
  imports = [
    (let
      commit = "89bdef7994a20b5285454bf42c7d2b53b98d5754";
      sha256 = "1gpp5bs1d9z6m1hg166czhdas0hnc787c1kbv7mp84drjyr9ny81";
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
