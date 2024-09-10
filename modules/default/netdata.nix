# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=340073

{ modulesPath, ... }:
let
  src = let
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "c7b89e5069fa2f34634059ae00ddf14dc6dd5eb4";
    sha256 = "sha256:1l3jhbidannc543ygq5f5z79g4a66p2959z6saml5nq9328y689m";
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
