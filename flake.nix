{
  description = "My Systems flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix = {
      url = "github:the-argus/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, firefox-addons, home-manager, nixos-hardware, pre-commit-hooks, spicetify-nix, ... }@inputs:
    let inherit (inputs.nixpkgs) lib;
    in {
      nixosModules = {
        default = import ./modules/default;

        profiles = import ./modules/profiles;
        colors = import ./modules/colors.nix;
        home-manager.imports = [ inputs.spicetify-nix.homeManagerModule ./modules/home-manager ];
      };

      overlays.default = lib.composeManyExtensions ([
        (_: super: {
          firefox-addons = inputs.firefox-addons.packages.${super.system};
          spicetify = inputs.spicetify-nix.packages.${super.system}.default;
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

          nix.nixPath = [ "nixpkgs=${nixpkgs}" ];

          _module.args = {
            inherit (self.nixosModules) colors;
            public-keys = import ./configuration/public-keys.nix;
            secrets = import ./secrets.nix;
          };
        };

        Laptop = {
          deployment.targetHost = "127.0.0.1";

          imports = [
            inputs.nixos-hardware.nixosModules.lenovo-legion-15ach6

            self.nixosModules.profiles.headful

            self.nixosModules.profiles.hidpi
            self.nixosModules.profiles.java
            self.nixosModules.profiles.javascript
            self.nixosModules.profiles.kotlin
            self.nixosModules.profiles.laptop-power-management
            self.nixosModules.profiles.podman
            self.nixosModules.profiles.python

            ./configuration/devices/laptop

            inputs.home-manager.nixosModule
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = false;

                extraSpecialArgs.colors = self.nixosModules.colors;

                users.rhoriguchi = self.nixosModules.home-manager;
              };
            }
          ];

          services.openssh.openFirewall = false;

          boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
        };

        #####################################################

        Server = {
          deployment.targetHost = "home.00a.ch";

          imports = [
            self.nixosModules.profiles.headless

            self.nixosModules.profiles.docker
            self.nixosModules.profiles.zfs

            ./configuration/devices/headless/server
          ];
        };

        AdGuard = {
          deployment.targetHost = "adguard";

          imports = [
            inputs.nixos-hardware.nixosModules.raspberry-pi-4

            self.nixosModules.profiles.headless

            ./configuration/devices/headless/raspberry-pi-4-b-8gb/adguard
          ];
        };

        #####################################################

        Grimmjow = {
          deployment.targetHost = "xxlpitu-grimmjow";

          imports = [
            inputs.nixos-hardware.nixosModules.raspberry-pi-4

            self.nixosModules.profiles.headless

            ./configuration/devices/headless/raspberry-pi-4-b-8gb/grimmjow
          ];
        };

        Ulquiorra = {
          deployment.targetHost = "xxlpitu-ulquiorra";

          imports = [
            inputs.nixos-hardware.nixosModules.raspberry-pi-4

            self.nixosModules.profiles.headless

            ./configuration/devices/headless/raspberry-pi-4-b-8gb/ulquiorra
          ];
        };
      };
    } // inputs.flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [ self.overlays.default ];
        };
      in {
        checks = {
          pre-commit = inputs.pre-commit-hooks.lib.${system}.run {
            src = ./.;

            hooks = {
              deadnix = {
                enable = true;
                excludes = [ "hardware-configuration\\.nix" ];
              };
              markdownlint.enable = true;
              nixfmt.enable = true;
            };

            settings = {
              markdownlint.config.MD013 = false;
              nixfmt.width = 140;
            };
          };
        } // (import ./checks { inherit pkgs; });

        devShells.default = pkgs.mkShell {
          buildInputs = [
            # TODO remove version pinning when nixops works with nix 2.15
            pkgs.nixVersions.nix_2_14
            (pkgs.nixopsUnstable.withPlugins (_: [ ]))
          ];
          shellHook = self.checks.${system}.pre-commit.shellHook;
        };
      });
}
