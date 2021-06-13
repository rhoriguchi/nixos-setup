{
  imports = [
    (let
      commit = "fb50102daf904c4ced33374816f9ee2cfde24c01";
      sha256 = "1j44f32fac98h77ygamcz1zyl2knnjim84dxg8j72jz1194f54gy";
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
