# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=424409
# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=424414
# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=426653
# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=426186

{ modulesPath, ... }:
let
  src = let
    owner = "rhoriguchi";
    repo = "nixpkgs";
    rev = "dbfc8801d5384eefa9246436c229b890db747f54";
    sha256 = "sha256:1dvnf0hiycgkwrcvgnxngyw4kh6vg1h0nkdvn88gpg54sl0dlf74";
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
