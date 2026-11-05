{
  description = "Pinned nixpkgs snapshots for unmerged module PRs";

  inputs = {
    "nixos/netdata" = {
      url = "github:NixOS/nixpkgs/pull/507414/head";
      flake = false;
    };

    "nixos/openlogi" = {
      url = "github:NixOS/nixpkgs/pull/583451/head";
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
        # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=507414
        netdata = mkOverride "services/monitoring/netdata" inputs."nixos/netdata";

        # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=583451
        openlogi = mkOverride "programs/openlogi" inputs."nixos/openlogi";
      };
    };
}
