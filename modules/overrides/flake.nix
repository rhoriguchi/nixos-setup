{
  description = "Pinned nixpkgs snapshots for unmerged module PRs";

  inputs = {
    bazarr = {
      url = "github:NixOS/nixpkgs/pull/519655/head";
      flake = false;
    };

    netdata = {
      url = "github:NixOS/nixpkgs/pull/507414/head";
      flake = false;
    };

    ollama = {
      url = "github:NixOS/nixpkgs/pull/561392/head";
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

      modules = {
        # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=519655
        bazarr = mkOverride "services/misc/bazarr" inputs.bazarr;

        # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=507414
        netdata = mkOverride "services/monitoring/netdata" inputs.netdata;

        # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=561392
        ollama = mkOverride "services/misc/ollama" inputs.ollama;
      };
    in
    {
      nixosModules = modules // {
        default.imports = builtins.attrValues modules;
      };
    };
}
