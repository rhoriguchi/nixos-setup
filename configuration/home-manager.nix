{
  imports = [
    (let
      commit = "a5c609b4b1cd4e1381ac8ea1b7d5b0792ebde0a3";
      sha256 = "0q8iq96sfrr8vxw36208bx2nbqx3r0i9s5hh75dxd5psc6p84vl4";
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
