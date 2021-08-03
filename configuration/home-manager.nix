{
  imports = [
    (let
      commit = "7f976da06840c268cc291a021bab7532b923713c";
      sha256 = "06ip8hxjm8mvwrjzrsp9l8zzj74rr2sy6x009pfyz5w6030axdpr";
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
