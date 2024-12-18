# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=340073

{ modulesPath, ... }:
let
  src = let
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "d17a879570f90e98540d8971fc71e685f950299a";
    sha256 = "sha256:1gn0lgb0rnhz7zrjbrkm209a1sjhpn558hb68c30p0shd5bq388s";
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
