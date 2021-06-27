{
  imports = [
    (let
      commit = "f4998f0adccc60a2b463f1892e3eb42b9715a8ee";
      sha256 = "0yq9b9iwabw2fgh0j96ka96rmyiyxqblswa26nb6fc1qrdyv21dr";
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
