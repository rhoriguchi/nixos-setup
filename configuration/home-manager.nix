{
  imports = [
    (let
      commit = "7add9ce2e5c517fcc4b25b3ed13e7e28cd325034";
      sha256 = "12wzr6f7xvyzgami0lbr3xsncg6jryabkgl59qc2fg79s951hins";
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
