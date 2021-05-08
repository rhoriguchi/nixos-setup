{
  imports = [
    (let
      commit = "4896c500742a2a2e86e71018e17e617c5ffc74c6";
      sha256 = "1j28n35d2gclcc4l2yk34dm9j4rc0z9rghs5hmckm7n2c0wvmw9y";
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
