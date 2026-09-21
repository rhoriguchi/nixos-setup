{
  description = "Pinned nixpkgs snapshots for unmerged module PRs";

  inputs = {
    bazarr = {
      url = "github:NixOS/nixpkgs/?rev=215cf43531f0449535bf3818562675c817bda11b";
      flake = false;
    };

    netdata = {
      url = "github:NixOS/nixpkgs/?rev=c0a8f331b280c32b83fc3ae3a28c38bcefeec449";
      flake = false;
    };

    ollama = {
      url = "github:NixOS/nixpkgs/?rev=ae98b3f341a74ab75a0ce317ac6b8023a6fb3672";
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
