# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=424414

{ modulesPath, ... }:
let
  src = let
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "f0140a7ca5c1e45e9195c45ff186fb74710ec77c";
    sha256 = "sha256:1j97k3115y15qpgn5i84z4rrgrq4cbh3k50ammz4kbrr2386srr5";
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
