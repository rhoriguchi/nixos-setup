{
  imports = [
    (let
      commit = "7591c8041d290d4bb99679e9fed2d8061a8f0435";
      sha256 = "09hbjw6n1yh8vhym79lckdp8a6wx7qmi9gr862w27zj8yqf3dl3q";
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
