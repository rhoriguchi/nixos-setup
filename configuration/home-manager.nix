{
  imports = [
    (let
      commit = "24ed6e6d4d8df7045b1fe38dedc3db179321eaa3";
      sha256 = "19csmnjx306x0r6md4wsgxdyngpgp6qmj78mjpfyx06pvwx7q738";
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
