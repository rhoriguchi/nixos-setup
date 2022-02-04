{
  imports = [
    (let
      commit = "63dccc4e60422c1db2c3929b2fd1541f36b7e664";
      sha256 = "0caa4746rg0ip2fkhwi1jklavk4lfgx1qvillrya6r3c2hbyx4rm";
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
