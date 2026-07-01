# TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=513794

{ modulesPath, ... }:
let
  src =
    let
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "dfbfeb5231c71e4daeb4a883f0b42e4103a42a6a";
      sha256 = "sha256:07rz9qq3br92wcb9v2d3sagdqb365p2hc1djmxizzycccnx5v8xw";
    in
    builtins.fetchTarball {
      name = "nixpkgs";
      url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
      inherit sha256;
    };
in
{
  disabledModules = [ "${modulesPath}/services/networking/syncthing-relay.nix" ];

  imports = [ "${src}/nixos/modules/services/networking/syncthing-relay.nix" ];
}
