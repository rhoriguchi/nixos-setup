{
  pkgs,
  self,
  nixTopology,
}:
let
  inherit (pkgs) lib;

  nixosConfigurations =
    lib.mapAttrs
      (
        name: cfg:
        cfg.extendModules {
          modules = [
            nixTopology.nixosModules.default

            {
              options.containers = lib.mkOption {
                type = lib.types.attrsOf (
                  lib.types.submodule {
                    config.config.imports = [ nixTopology.nixosModules.default ];
                  }
                );
              };
            }
          ]
          ++ lib.optionals (name == "XXLPitu-Tier") [
            {
              # nix-topology's home-assistant extractor reads `http.server_host`,
              # which Home Assistant has deprecated (home-assistant/core#157981)
              # and Tier's real config no longer sets. This override only exists
              # for topology rendering, it doesn't affect the deployed config.
              services.home-assistant.config.http.server_host = [ "0.0.0.0" ];
            }
          ];
        }
      )
      (
        lib.filterAttrs (
          name: _: lib.elem "home" (self.deploy.nodes.${name}.groups or [ ])
        ) self.nixosConfigurations
      );
in
import nixTopology {
  pkgs = pkgs.extend nixTopology.overlays.default;

  specialArgs = {
    inherit self;
  };

  modules = [
    ./config.nix
    { inherit nixosConfigurations; }
  ];
}
