# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=426653

{ modulesPath, ... }:
let
  src = let
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "463dfb9561037bb422533cfd1a0a6c84c51f4d07";
    sha256 = "sha256:0zgmbs9jzfblky5h2h87ng8rpqz468l0aqk2qk603l6ig51yf7iq";
  in builtins.fetchTarball {
    name = "nixpkgs";
    url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
    inherit sha256;
  };
in {
  disabledModules = [ "${modulesPath}/services/monitoring/netdata.nix" ];

  imports = [ "${src}/nixos/modules/services/monitoring/netdata.nix" ];

  nixpkgs.overlays = [ (_: super: { netdata = super.callPackage "${src}/pkgs/tools/system/netdata" { protobuf = super.protobuf_21; }; }) ];
}
