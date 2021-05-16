{
  imports = [
    (let
      commit = "77188bcd6e2c6c7a99253b36f08ed7b65f2901d2";
      sha256 = "0vnqic06ir9ccclr7qshiqi6k8zfrpzjvighnk89sbhzif16bwk8";
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
