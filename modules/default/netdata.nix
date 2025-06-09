# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=410815

{ modulesPath, ... }:
let
  src = let
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "a0e8a6b5c98be4d65315ce9fe66e901edbc917f8";
    sha256 = "sha256:0ckifnqmkkfmx7c8iwd2zglybkd0av7px9lxgnngkz1ll9pgq5i1";
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
