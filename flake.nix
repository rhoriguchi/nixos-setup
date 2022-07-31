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

    nur-rycee = {
      url = "gitlab:rycee/nur-expressions";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, mach-nix, nur-rycee, ... }@inputs:
    {
      nixosModules.default = import ./modules;

      overlays.default = inputs.nixpkgs.lib.composeManyExtensions ([
        (self: super:
          let nur-rycee = import inputs.nur-rycee { pkgs = super; };
          in {
            mach-nix = inputs.mach-nix.lib.${super.stdenv.hostPlatform.system};

            inherit (nur-rycee) firefox-addons;
          })
      ] ++ import ./overlays);

      nixopsConfigurations.default = {
        inherit (inputs) nixpkgs;

        network = {
          description = "My Systems";
          enableRollback = true;
          storage.legacy = { };
        };

        defaults = {
          imports = [
            self.nixosModules.default

            ./configuration/common.nix
          ];

          nixpkgs.overlays = [ self.overlays.default ];

          _module.args = {
            colors = import ./configuration/colors.nix;
            public-keys = import ./configuration/public-keys.nix;
            secrets = import ./configuration/secrets.nix;
          };
        };
      } // import ./devices.nix;
    } // inputs.flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import inputs.nixpkgs { inherit system; };
      in { devShells.default = pkgs.mkShell { buildInputs = [ pkgs.nix pkgs.nixopsUnstable ]; }; });
}
