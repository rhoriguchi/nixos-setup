# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=336919

{ modulesPath, ... }:
let
  src = let
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "ffb1e9ce980ff6acf971aca1e3cdd71a490ff7c8";
    sha256 = "sha256:0cp8xkjy4j4hn2b3wa0d5bxgg7iid0b6s1rcg65zc49xqyhv4rsh";
  in builtins.fetchTarball {
    name = "nixpkgs";
    url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
    inherit sha256;
  };
in {
  disabledModules = [ "${modulesPath}/services/monitoring/netdata.nix" ];

  imports = [ "${src}/nixos/modules/services/monitoring/netdata.nix" ];

  nixpkgs.overlays = [
    (_: super: {
      netdata = super.callPackage "${src}/pkgs/tools/system/netdata" {
        inherit (super.darwin.apple_sdk.frameworks) CoreFoundation IOKit;
        protobuf = super.protobuf_21;
      };
    })
  ];
}
