{
  description = "My Systems flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    nur-rycee = {
      url = "gitlab:rycee/nur-expressions";
      flake = false;
    };

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, home-manager, mach-nix, nixos-hardware, nur-rycee, pre-commit-hooks, ... }@inputs:
    let inherit (inputs.nixpkgs) lib;
    in {
      nixosModules = {
        default = import ./modules;

        colors = import ./colors.nix;
        home = import ./home;
        templates = import ./templates;
      };

      overlays.default = lib.composeManyExtensions ([
        (_: super:
          let nur-rycee-pkgs = import inputs.nur-rycee { pkgs = super; };
          in {
            mach-nix = inputs.mach-nix.lib.${super.stdenv.hostPlatform.system};

            inherit (nur-rycee-pkgs) firefox-addons;
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
            inherit (inputs) nixpkgs;
            inherit (self.nixosModules) colors;
            public-keys = import ./configuration/public-keys.nix;
            secrets = import ./secrets.nix;
          };
        };

        Laptop = {
          deployment.targetHost = "127.0.0.1";

          imports = [
            inputs.nixos-hardware.nixosModules.lenovo-legion-15ach6

            self.nixosModules.templates.headful

            self.nixosModules.templates.hidpi
            self.nixosModules.templates.java
            self.nixosModules.templates.javascript
            self.nixosModules.templates.kotlin
            self.nixosModules.templates.laptop-power-management
            self.nixosModules.templates.podman
            self.nixosModules.templates.python

            ./configuration/devices/laptop

            inputs.home-manager.nixosModule
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = false;

                extraSpecialArgs = {
                  inherit (self.nixosModules) colors;
                  conkyConfig = {
                    fileSystems = [ "/" ];
                    interfaces = [ "wlp2s0" ];
                  };
                };

                users.rhoriguchi = self.nixosModules.home;
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
            self.nixosModules.templates.headless

            self.nixosModules.templates.docker

            ./configuration/devices/headless/server
          ];
        };

        AdGuard = {
          deployment.targetHost = "xxlpitu-adguard";

          imports = [
            inputs.nixos-hardware.nixosModules.raspberry-pi-4

            self.nixosModules.templates.headless

            ./configuration/devices/headless/raspberry-pi-4-b-8gb/adguard
          ];
        };

        JDH-Server = {
          deployment.targetHost = "jdh-server";

          imports = [
            self.nixosModules.templates.headless

            ./configuration/devices/headless/jdh-server
          ];
        };

        #####################################################

        Grimmjow = {
          deployment.targetHost = "xxlpitu-grimmjow";

          imports = [
            inputs.nixos-hardware.nixosModules.raspberry-pi-4

            self.nixosModules.templates.headless

            ./configuration/devices/headless/raspberry-pi-4-b-8gb/grimmjow
          ];
        };

        Ulquiorra = {
          deployment.targetHost = "xxlpitu-ulquiorra";

          imports = [
            inputs.nixos-hardware.nixosModules.raspberry-pi-4

            self.nixosModules.templates.headless

            ./configuration/devices/headless/raspberry-pi-4-b-8gb/ulquiorra
          ];
        };
      };
    } // inputs.flake-utils.lib.eachSystem (let inherit (inputs.flake-utils.lib) system; in [ system.aarch64-linux system.x86_64-linux ])
    (system:
      let
        pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
        };
      in {
        checks.pre-commit = inputs.pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = let tools = inputs.pre-commit-hooks.packages.${system};
          in {
            deadnix = {
              enable = true;
              excludes = [ "hardware-configuration\\.nix" ];
            };
            markdownlint = {
              enable = true;
              entry = lib.mkForce "${tools.markdownlint-cli}/bin/markdownlint --disable MD013";
            };
            nixfmt = {
              enable = true;
              entry = lib.mkForce "${tools.nixfmt}/bin/nixfmt --width=140";
            };
          };
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [ pkgs.nix pkgs.nixopsUnstable ];
          shellHook = self.checks.${system}.pre-commit.shellHook;
        };
      });
}
