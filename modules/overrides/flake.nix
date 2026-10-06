{
  description = "Pinned nixpkgs snapshots for unmerged module PRs";

  inputs = {
    "nixos/adguardhome" = {
      url = "github:NixOS/nixpkgs/pull/568438/head";
      flake = false;
    };

    "nixos/bazarr" = {
      url = "github:NixOS/nixpkgs/pull/519655/head";
      flake = false;
    };

    "nixos/netdata" = {
      url = "github:NixOS/nixpkgs/pull/507414/head";
      flake = false;
    };
  };

  outputs =
    { ... }@inputs:
    let
      mkOverride =
        path: src:
        { modulesPath, ... }:
        {
          disabledModules = [ "${modulesPath}/${path}.nix" ];
          imports = [ "${src}/nixos/modules/${path}.nix" ];
        };
    in
    {
      nixosModules.default.imports = builtins.attrValues {
        # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=568438
        adguardhome = mkOverride "services/networking/adguardhome" inputs."nixos/adguardhome";

        # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=519655
        bazarr = mkOverride "services/misc/bazarr" inputs."nixos/bazarr";

        # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=507414
        netdata = mkOverride "services/monitoring/netdata" inputs."nixos/netdata";
      };
    };
}
