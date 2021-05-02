{
  imports = [
    (let
      commit = "ca7868dc2977e2bdb4b1c909768c686d4ec0a412";
      sha256 = "0xaz21qn3jz2y0wi6m7f6p7xmzzmbm9d6x1zv4zg5myp0kcx8fq5";
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
