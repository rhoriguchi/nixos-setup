{
  imports = [
    (let
      commit = "970b57fd3c93f6c76d5cdfb4da23a5b4010b9e8b";
      sha256 = "0abl8dd03xs39lyvwmd1xay1a5wshiyhh5vh6xk77cdh3dzz9l0z";
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
