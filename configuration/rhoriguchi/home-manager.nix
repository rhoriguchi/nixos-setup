{
  imports = [
    (let
      commit = "ff616b273426b528ae15f1b042863a4828dc1d88";
      sha256 = "0p44znwg05bb1srkgqq46lh14gnj1w1cy87gkl1n7nd3iiw52qak";
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
