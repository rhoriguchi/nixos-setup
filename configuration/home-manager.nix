{
  imports = [
    (let
      commit = "c27c8f49c0bccaff91f5f637ad727d440b769997";
      sha256 = "0x6kasdiff80r2glkr5kml6rjrwv8rv9pwm0pz3x3rs0q139jr2f";
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
