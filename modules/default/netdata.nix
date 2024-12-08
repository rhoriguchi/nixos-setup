# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=340073
# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=363038

{ modulesPath, ... }:
let
  src = let
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "aa845ceb1f8301c248496d33670c471e9a778ca6";
    sha256 = "sha256:1fg6m9grqsyq8h5wrrv8yw97m3npap0mbvxys0zaglcci0ch0dri";
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
