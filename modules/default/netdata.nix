# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=433994
# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=433990
# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=426186

{ modulesPath, ... }:
let
  src = let
    owner = "rhoriguchi";
    repo = "nixpkgs";
    rev = "e7ca22650876e270c426cf04ddebd1656e3d2ace";
    sha256 = "sha256:1sp9klmq4qfhi5xlv1v10mm9psr7r9zz6b17vif6mfkhmjb152zb";
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
