{
  imports = [
    (let
      commit = "ebbbd4f2b50703409543941e7445138dc1e7392e";
      sha256 = "01d327d24ac8hc2b01m7v3zprr2mjaj3qyw7lkvp9bp21pwnvmvw";
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
