{
  imports = [
    (let
      commit = "781d25b315def05cd7ede3765226c54216f0b1fe";
      sha256 = "14cbfsslf1qbgkif3hrgn6x5rxa9h6b61jh4jmjbfi6mbnxvn8r9";
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
