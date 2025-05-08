# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=405728

{ modulesPath, ... }:
let
  src = let
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "a6a8c41cd6e740aafc9e431abaacafb2a83f72a2";
    sha256 = "sha256:0chzq2m9hppb03hzs83x0z5ymwmcvhd4ad7mb601d97ziprfgv6f";
  in builtins.fetchTarball {
    name = "nixpkgs";
    url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
    inherit sha256;
  };
in {
  disabledModules = [ "${modulesPath}/services/networking/bind.nix" ];

  imports = [ "${src}/nixos/modules/services/networking/bind.nix" ];
}
