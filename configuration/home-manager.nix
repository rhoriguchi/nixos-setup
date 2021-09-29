{
  imports = [
    (let
      commit = "959217e51dbd07d0de6dcbddfbfcb4f2efdc0c1e";
      sha256 = "1hhdk23rd5drgpm8pfpkyg1dl2fgn0pqwandx96qhqdv7k44lqnh";
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
