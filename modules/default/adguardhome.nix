# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=247828

{ modulesPath, ... }:
let
  src = let
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "298d44c7f252dcfaf941fa30050cecb111e242cd";
    sha256 = "sha256:0vcpjn8yb15xrf73bvdkbn0mn9m7ywdv7l26c5s1grarwqwy5sbx";
  in builtins.fetchTarball {
    name = "nixpkgs";
    url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
    inherit sha256;
  };
in {
  disabledModules = [ "${modulesPath}/services/networking/adguardhome.nix" ];

  imports = [ "${src}/nixos/modules/services/networking/adguardhome.nix" ];

  nixpkgs.overlays = [ (_: super: { adguardhome = super.callPackage (import "${src}/pkgs/servers/adguardhome") { }; }) ];
}
