{
  description = "PiKVM kvmd package and NixOS module";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    in
    {
      overlays.default = final: _: {
        pykvmd = final.callPackage ./package.nix {
          python3Packages = final.python314Packages;
        };
      };

      packages = nixpkgs.lib.genAttrs systems (system: {
        inherit (nixpkgs.legacyPackages.${system}.extend self.overlays.default) pykvmd;
      });

      nixosModules.default = ./module.nix;
    };
}
