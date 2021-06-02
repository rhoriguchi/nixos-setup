{
  imports = [
    (let
      commit = "cb227dc6c29eb4f768d04958f4fe6d9d3d4aba46";
      sha256 = "0bml52vamdfy452gygf7508n6napxz16vfxmacif0mxnrp30dmyb";
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

    users.rhoriguchi = {
      news.display = "silent";

      manual = {
        html.enable = false;
        json.enable = false;
      };
    };
  };
}
