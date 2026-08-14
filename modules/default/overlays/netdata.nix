# TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=545582

{ modulesPath, ... }:
let
  src =
    let
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "2669b351053f74add70e36a0495cbadaa6f7a17d";
      sha256 = "sha256-w77h8zOQIreXc/U0AmitFM3EIIYn46l8T5fw5/7zPSQ=";
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
    (final: prev: {
      netdata = prev.callPackage (import "${src}/pkgs/tools/system/netdata") { };

      python3 = prev.python3.override {
        packageOverrides = _: _: {
          netdata-pandas =
            prev.python3Packages.callPackage
              (import "${src}/pkgs/development/python-modules/netdata-pandas/default.nix")
              { };
        };
      };

      python3Packages = final.python3.pkgs;
    })
  ];
}
