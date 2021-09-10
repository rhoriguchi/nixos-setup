{
  imports = [
    (let
      commit = "039f786e609fdb3cfd9c5520ff3791750c3eaebf";
      sha256 = "0bf1dsx4l7c0a1ypmwp0dg6y8f5qds8nxkwzjijmdf7jc4kz0phb";
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
