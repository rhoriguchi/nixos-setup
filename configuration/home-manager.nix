{
  imports = [
    (let
      commit = "72f3bc6fa461a2899a06c87c137c7135e410e387";
      sha256 = "19346841har81bgj4vfb2ks222846ng185fcdhrwygxj6m3kbw5v";
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
