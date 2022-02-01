{
  imports = [
    (let
      commit = "a52aed72c84a2a10102a92397339fa01fc0fe9cf";
      sha256 = "1z9v3r2hds8ww7vm383m9fb8ilpkwd747xacikczsxraw3ihqpmm";
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
