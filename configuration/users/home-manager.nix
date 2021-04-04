{
  imports = [
    (let
      commit = "25a6a6d2984e70c9a07c8f8a69ebe24e6c700abf";
      sha256 = "1kz06psapzb3chwjkmxl6w6n1a1gmhhxm0bcx268v434ljrx4wry";
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
