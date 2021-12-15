{
  imports = [
    (let
      commit = "c61fc1c288bd1fdf96261ba5574a12cf8f9be70b";
      sha256 = "1d2yi74flhdsbdggkmi9w5f08r5z9h5cdyxsdp3qdmw08s20a1zb";
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
