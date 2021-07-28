{
  imports = [
    (let
      commit = "2272fc312d5dc477e70816d94e550d08729b307b";
      sha256 = "0s5f95sn0pif93r49zrmkf6ij74ml5i0k0zlzpgpp69k718qyvdc";
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
