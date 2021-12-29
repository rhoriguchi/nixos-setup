{
  imports = [
    (let
      commit = "2f40cd05dc0ffe3ba69a94e9e76e0357c5b9a0b8";
      sha256 = "0a5v0h9s5wyhi0w0vxi25wawns5y2ncmqmzln0xyi9mcrh7rqpa6";
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
