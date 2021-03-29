{
  imports = [
    (let
      commit = "c1761366b522595ff0dda47d7ba79d5242ecb31e";
      sha256 = "13z0nrzx6g6ls4nl31ac1nq0s2qaslqai55d94bancvzhbklpn37";
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
