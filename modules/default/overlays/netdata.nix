# TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=507414

{ modulesPath, ... }:
let
  src =
    let
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "c0a8f331b280c32b83fc3ae3a28c38bcefeec449";
      sha256 = "sha256-DvGMzhpC2dQYODCw81zpPpIU/o/hc8pDCLKjcQeN6Y8=";
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
}
