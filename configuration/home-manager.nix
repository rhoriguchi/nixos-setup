{
  imports = [
    (let
      commit = "d119cea3763977801ad66330668c1ab4346cb7f7";
      sha256 = "1vih17qyf8bfjqw5lnilfjhl22l6qdh6rjvwdjz1zpjvxy86zkg3";
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
