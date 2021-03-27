{
  imports = [
    (let
      commit = "7b30fc99227e6c7c331a01a9fb87599e4cd8cee1";
      sha256 = "0hqzswcprr6myfscizswb7cm73149r6742biswrc9yqvig9wxl2k";
    in "${
      fetchTarball {
        url =
          "https://github.com/nix-community/home-manager/archive/${commit}.tar.gz";
        inherit sha256;
      }
    }/nixos")
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };
}
