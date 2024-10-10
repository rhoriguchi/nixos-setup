# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=340073
# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=347790

{ modulesPath, ... }:
let
  src = let
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "19e47eeaecbddc79c19768aa4ec50504159fdbb7";
    sha256 = "sha256:097i74xwdi5vq20lhswzcbvqzrdzviqgfz3hhcnnvzjsqz4cimqk";
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
