# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=433994
# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=433990
# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=436005

{ modulesPath, ... }:
let
  src = let
    owner = "rhoriguchi";
    repo = "nixpkgs";
    rev = "ed3a023540707731290c6a8df22ef5c4ca1996d1";
    sha256 = "sha256:1q24d149pkhl9a7g6rni7w8xxkp9w1y8m2a67cpijzz28wl041wm";
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
