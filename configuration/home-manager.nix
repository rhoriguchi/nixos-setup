{
  imports = [
    (let
      commit = "7c2ae0bdd20ddcaafe41ef669226a1df67f8aa06";
      sha256 = "017b3v16zas9914d7pbqva1fg3bdi7wrqrlks5pbymrr2ypb3v64";
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
