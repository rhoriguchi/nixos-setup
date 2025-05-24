# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=410501

{ modulesPath, ... }:
let
  src = let
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "fa4d5f256fe84457da3ad8d130464be86478ab42";
    sha256 = "sha256:0pmvnq1xss6hj6478m7w9qhk0gdnxlvw0x0jxb8d6cy09j7mcf4m";
  in builtins.fetchTarball {
    name = "nixpkgs";
    url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
    inherit sha256;
  };
in {
  disabledModules = [ "${modulesPath}/services/networking/bind.nix" ];

  imports = [ "${src}/nixos/modules/services/networking/bind.nix" ];
}
