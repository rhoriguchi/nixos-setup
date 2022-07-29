{
  description = "My Systems flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    mach-nix = {
      url = "github:DavHau/mach-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        pypi-deps-db.follows = "pypi-deps-db";
      };
    };
    pypi-deps-db = {
      url = "github:DavHau/pypi-deps-db";
      flake = false;
    };

    nur.url = "github:nix-community/NUR";
  };

  outputs = { self, nixpkgs, flake-utils, mach-nix, nur, ... }:
    {
      # TODO find out how to make this compliant https://nixos.wiki/wiki/Flakes#Output_schema

      modules = import ./modules;

      overlays = [
        nur.overlay
        (self: super: {
          mach-nix = mach-nix.lib.${super.stdenv.hostPlatform.system};

          nur = { };
          inherit (super.nur.repos.rycee) firefox-addons;
        })
      ] ++ import ./overlays;

      nixopsConfigurations.default = {
        inherit nixpkgs;

        network = {
          description = "My Systems";
          enableRollback = true;
          storage.legacy = { };
        };

        defaults = {
          imports = [ ./configuration/common.nix ];

          nixpkgs.overlays = self.overlays;

          _module.args = {
            colors = import ./configuration/colors.nix;
            public-keys = import ./configuration/public-keys.nix;
            secrets = import ./configuration/secrets.nix;
          };
        };
      } // import ./devices.nix;
    } // flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; };
      in { devShell = pkgs.mkShell { buildInputs = [ pkgs.nix pkgs.nixopsUnstable ]; }; });
}
