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
        # kvmd requires python>=3.14,<3.15, don't follow the python3 default
        # https://github.com/pikvm/kvmd/blob/v4.233/PKGBUILD#L50-L51
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
