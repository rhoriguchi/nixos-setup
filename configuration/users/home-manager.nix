{
  imports = [
    (let
      commit = "56f5f41ed42f7d476a7c79fa8ec71f5605487abf";
      sha256 = "15kdakm06xrx2gkk17a79661asm83b3ap7y9dilqxap0sp2bflff";
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
