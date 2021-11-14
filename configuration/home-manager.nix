{
  imports = [
    (let
      commit = "accfbdf215dbf39eac2fbae67b574dac0be83d51";
      sha256 = "03xc2vspwmmkkvwbgd163ppqmhq92m6agw30jnnh0gqf71naazc4";
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
