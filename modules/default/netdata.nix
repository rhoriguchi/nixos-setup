# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=433994
# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=433990

{ modulesPath, ... }:
let
  src =
    let
      owner = "rhoriguchi";
      repo = "nixpkgs";
      rev = "680718e34c3b227773477f02c7b84f9bdc4b6dae";
      sha256 = "sha256:0cp9mdnyiyaa7vh9gwffgdl3plhgwrdi9886phzs6k4x9b4w0bc9";
    in
    builtins.fetchTarball {
      name = "nixpkgs";
      url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
      inherit sha256;
    };
in
{
  disabledModules = [ "${modulesPath}/services/monitoring/netdata.nix" ];

  imports = [ "${src}/nixos/modules/services/monitoring/netdata.nix" ];

  nixpkgs.overlays = [
    (_: super: {
      netdata = super.callPackage "${src}/pkgs/tools/system/netdata" { protobuf = super.protobuf_21; };
    })
  ];
}
