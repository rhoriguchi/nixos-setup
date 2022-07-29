{
  description = "My Systems flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    mach-nix = {
      url = "github:DavHau/mach-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";
  };

  outputs = { self, nixpkgs, flake-utils, mach-nix, nur, ... }:
    rec {
      overlays = [
        nur.overlay
        (self: super: {
          mach-nix = mach-nix.lib.${super.stdenv.hostPlatform.system};

          nur = { };
          inherit (super.nur.repos.rycee) firefox-addons;
        })
      ] ++ import ./configuration/overlays;

      nixopsConfigurations.default = {
        inherit nixpkgs;

        network = {
          description = "My Systems";
          enableRollback = true;
          storage.legacy = { };
        };

        defaults = {
          imports = [ ./configuration/common.nix ];

          nixpkgs = { inherit overlays; };

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
