{
  description = "My Systems flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-minecraft = {
      url = "github:Infinidoge/nix-minecraft";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
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

  outputs = { self, nixpkgs, deploy-rs, flake-utils, firefox-addons, home-manager, nix-minecraft, nix-index-database, nixos-hardware
    , pre-commit-hooks, spicetify-nix, ... }@inputs:
    let inherit (inputs.nixpkgs) lib;
    in {
      nixosModules = {
        default.imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ./modules/default ];

        profiles = import ./modules/profiles;
        colors = import ./modules/colors.nix;
        home-manager.imports =
          [ inputs.nix-index-database.hmModules.nix-index inputs.spicetify-nix.homeManagerModule ./modules/home-manager ];
      };

      overlays.default = lib.composeManyExtensions ([
        inputs.deploy-rs.overlays.default

        inputs.nix-minecraft.overlay

        (_: super: {
          firefox-addons = inputs.firefox-addons.packages.${super.system};
          spicetify = inputs.spicetify-nix.packages.${super.system}.default;
        })
      ] ++ import ./overlays);

      deploy.nodes = let
        commonModule = {
          imports = [ self.nixosModules.default ];

          system.configurationRevision = self.rev or self.dirtyRev or null;

          nixpkgs.overlays = [ self.overlays.default ];

          nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

          _module.args = {
            inherit (self.nixosModules) colors;
            public-keys = import ./configuration/public-keys.nix;
            secrets = import ./secrets.nix;
          };
        };
      in {
        # Lenovo Legion 5 15ACH6
        Laptop = let system = inputs.flake-utils.lib.system.x86_64-linux;
        in {
          hostname = "127.0.0.1";

          profilesOrder = [ "system" "rhoriguchi-home-manager" ];

          profiles = {
            system = {
              sshUser = "root";

              path = inputs.deploy-rs.lib.${system}.activate.nixos (inputs.nixpkgs.lib.nixosSystem {
                modules = [{
                  imports = [
                    commonModule

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
                  ];

                  services.openssh.openFirewall = false;

                  boot.binfmt.emulatedSystems = [ inputs.flake-utils.lib.system.aarch64-linux ];

                  # TODO required for obsidian
                  nixpkgs.config.permittedInsecurePackages = [ "electron-25.9.0" ];
                }];
              });
            };

            rhoriguchi-home-manager = {
              sshUser = "root";
              user = "rhoriguchi";

              # TODO does not seem to work
              profilePath = "/nix/var/nix/profiles/per-user/rhoriguchi/home-manager";
              path = inputs.deploy-rs.lib.${system}.activate.home-manager (inputs.home-manager.lib.homeManagerConfiguration {
                pkgs = inputs.nixpkgs.legacyPackages.${system};

                modules = [
                  {
                    nixpkgs.overlays = [ self.overlays.default ];

                    home = {
                      username = "rhoriguchi";
                      homeDirectory = "/home/rhoriguchi";

                      sessionVariables.NIX_PATH = "nixpkgs=${inputs.nixpkgs}";
                    };
                  }

                  self.nixosModules.home-manager
                ];

                extraSpecialArgs.colors = self.nixosModules.colors;
              });
            };
          };
        };

        Server = let system = inputs.flake-utils.lib.system.x86_64-linux;
        in {
          hostname = "home.00a.ch";

          profiles.system = {
            sshUser = "root";

            path = inputs.deploy-rs.lib.${system}.activate.nixos (inputs.nixpkgs.lib.nixosSystem {
              modules = [{
                imports = [
                  commonModule

                  self.nixosModules.profiles.headless

                  self.nixosModules.profiles.zfs

                  ./configuration/devices/headless/server
                ];
              }];
            });
          };
        };

        # Raspberry Pi 4 Model B - 8GB
        Grimmjow = let system = inputs.flake-utils.lib.system.aarch64-linux;
        in {
          hostname = "xxlpitu-grimmjow";

          profiles.system = {
            sshUser = "root";

            path = inputs.deploy-rs.lib.${system}.activate.nixos (inputs.nixpkgs.lib.nixosSystem {
              modules = [{
                imports = [
                  commonModule

                  inputs.nixos-hardware.nixosModules.raspberry-pi-4

                  self.nixosModules.profiles.headless

                  ./configuration/devices/headless/raspberry-pi-4/grimmjow
                ];
              }];
            });
          };
        };

        # Raspberry Pi 4 Model B - 8GB
        Nelliel = let system = inputs.flake-utils.lib.system.aarch64-linux;
        in {
          hostname = "xxlpitu-nelliel";

          profiles.system = {
            sshUser = "root";

            path = inputs.deploy-rs.lib.${system}.activate.nixos (inputs.nixpkgs.lib.nixosSystem {
              modules = [{
                imports = [
                  commonModule

                  inputs.nixos-hardware.nixosModules.raspberry-pi-4

                  self.nixosModules.profiles.headless

                  ./configuration/devices/headless/raspberry-pi-4/nelliel
                ];
              }];
            });
          };
        };

        Ulquiorra = let
          system = inputs.flake-utils.lib.system.aarch64-linux;
          # Raspberry Pi 4 Model B - 8GB
        in {
          hostname = "xxlpitu-ulquiorra";

          profiles.system = {
            sshUser = "root";

            path = inputs.deploy-rs.lib.${system}.activate.nixos (inputs.nixpkgs.lib.nixosSystem {
              modules = [{
                imports = [
                  commonModule

                  inputs.nixos-hardware.nixosModules.raspberry-pi-4

                  self.nixosModules.profiles.headless

                  ./configuration/devices/headless/raspberry-pi-4/ulquiorra
                ];
              }];
            });
          };
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
              actionlint.enable = true;
              deadnix = {
                enable = true;
                excludes = [ "hardware-configuration\\.nix" ];
              };
              markdownlint = {
                enable = true;

                settings.config.MD013 = false;
              };
              nixfmt = {
                enable = true;
                excludes = [ "secrets\\.nix" ];

                settings.width = 140;
              };
            };
          };
        } // (inputs.deploy-rs.lib.${system}.deployChecks self.deploy) // (import ./checks { inherit pkgs; });

        devShells.default = pkgs.mkShell {
          buildInputs = [ inputs.deploy-rs.packages.${system}.deploy-rs pkgs.nix-output-monitor pkgs.nixUnstable ];
          shellHook = self.checks.${system}.pre-commit.shellHook;
        };
      });
}
