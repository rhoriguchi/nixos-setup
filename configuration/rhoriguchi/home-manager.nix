{
  imports = [
    (let
      commit = "86944b0fb15f89bc1173efabbce556260a410154";
      sha256 = "1hkhcx4cdn4snwd6931jj5c9vwd4yn4b7aprz3z7n8sqhcspm1n3";
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
