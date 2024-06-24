# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=321644

{ modulesPath, ... }:
let
  src = let
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "53a03f272c8af6c9fc8b799cb536ee2549466d72";
    sha256 = "sha256:0lm51ayy6vwi0bnkdan5nmyk5bldmsgk4nki6vvf7zvsykc24y6b";
  in builtins.fetchTarball {
    name = "nixpkgs";
    url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
    inherit sha256;
  };
in {
  disabledModules = [ "${modulesPath}/services/monitoring/netdata.nix" ];

  imports = [ "${src}/nixos/modules/services/monitoring/netdata.nix" ];
}
