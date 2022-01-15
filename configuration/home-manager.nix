{
  imports = [
    (let
      commit = "a5dd5d5f197724f3065fd39c59c7ccea3c8dcb8f";
      sha256 = "1il82ld3yv79mdr02yw6s5xmw31dz80ax22j9a8ris76xw2z2azx";
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
