{
  imports = [
    (let
      commit = "0a6227d667d1d2bc6a79de24fd12becc523f2e2f";
      sha256 = "0gwjhr68ds2kyx06xqlfimp5d37b7ny95n0sbhryjnxnhbnmhbpp";
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
