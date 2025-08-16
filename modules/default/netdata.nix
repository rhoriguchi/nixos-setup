# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=433994
# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=433990
# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=426186

{ modulesPath, ... }:
let
  src = let
    owner = "rhoriguchi";
    repo = "nixpkgs";
    rev = "db3a22c721e220c1dd8f563250722057d8b042ad";
    sha256 = "sha256:00jfxf0w5sj1vrxdfdj743yi1rnpram2qh2xkg70dmdqq0cmdi3v";
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
