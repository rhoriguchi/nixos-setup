{
  imports = [
    (let
      commit = "92f58b6728e7c631a7ea0ed68cd21bb29a4876ff";
      sha256 = "02ccqnc0s9pdrcwm4lzp8fwaamgrgka0jjsipl2h4bsbgv7djql7";
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
