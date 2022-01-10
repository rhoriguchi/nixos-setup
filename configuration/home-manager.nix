{
  imports = [
    (let
      commit = "f3be3cda6a69365f2acecc201b3cd1ee4f6d4614";
      sha256 = "19ha58d17ng2ab6wvkkibn87w4mkzmv3hfv9akp9dsy2mbiykgvz";
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
