{
  imports = [
    (let
      commit = "c491331718bd41722a2982a5532eb0ff51c3ca28";
      sha256 = "0nirmf81l5iqwrdrdjx6kzp2pkbqrcml0gq41infi8nf633pgghd";
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
