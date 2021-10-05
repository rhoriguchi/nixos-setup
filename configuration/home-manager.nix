{
  imports = [
    (let
      commit = "80d23ee06cff0d0bef20b9327566f7de2498f4cb";
      sha256 = "1vbps9ckhzk6qvxmzps4q75sm0274yf9vcp14ybnmlp0zjlh117m";
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
