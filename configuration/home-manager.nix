{
  imports = [
    (let
      commit = "0b47ded208a6ed24f40b9d62379d04fe8dc4f63e";
      sha256 = "1kzvj43v05adx7szapph3xdyicnpwmawkjrzhhigkqnij1jqibws";
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
