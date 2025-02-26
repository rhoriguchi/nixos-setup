{
  description = "Systems flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";

    borg-exporter = {
      url = "git+https://codeberg.org/k0ral/borg-exporter.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

    nix-github-actions = {
      url = "github:nix-community/nix-github-actions";
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

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, ... }@inputs:
    let lib = inputs.nixpkgs.lib.extend self.overlays.lib;
    in {
      githubActions = inputs.nix-github-actions.lib.mkGithubMatrix {
        checks = let
          filterAttrs = attrs: lib.filterAttrs (key: _: !(builtins.elem key [ "deploy-activate" "deploy-schema" ])) attrs;
          removeChecks = checks: lib.mapAttrs (_: system: filterAttrs system) checks;
        in lib.getAttrs [ "x86_64-linux" ] (removeChecks self.checks);
      };

      nixosModules = {
        default.imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ./modules/default ];

        profiles = import ./modules/profiles;
        colors = import ./modules/colors.nix;
        home-manager.imports = [ inputs.nix-index-database.hmModules.nix-index ./modules/home-manager ];
      };

      overlays = {
        default = lib.composeManyExtensions ([
          inputs.deploy-rs.overlays.default
          inputs.nix-minecraft.overlay

          (_: super: {
            borg-exporter-image = inputs.borg-exporter.defaultPackage.${super.system};
            firefox-addons = inputs.firefox-addons.packages.${super.system};
          })
        ] ++ import ./overlays);

        lib = (_: super: { custom = import ./lib.nix { lib = super; }; });
      };

      nixosConfigurations = let
        commonModule = {
          imports = [ self.nixosModules.default ];

          system.configurationRevision = self.rev or self.dirtyRev or null;

          nix.registry.nixpkgs.flake = inputs.nixpkgs;

          nixpkgs.overlays = [ self.overlays.default ];

          _module.args = {
            inherit (self.nixosModules) colors;
            public-keys = import ./public-keys.nix;
            secrets = import ./secrets.nix;
          };
        };
      in {
        # Lenovo Legion 5 15ACH6
        Laptop = lib.nixosSystem {
          system = "x86_64-linux";

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

              inputs.home-manager.nixosModules.home-manager
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;

                  extraSpecialArgs.colors = self.nixosModules.colors;

                  users.rhoriguchi.imports = [ self.nixosModules.home-manager ];
                };
              }
            ];

            boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
          }];
        };

        # Gowin R86S-N N305A
        XXLPitu-Router = lib.nixosSystem {
          system = "x86_64-linux";

          modules = [{
            imports = [
              commonModule

              self.nixosModules.profiles.headless

              ./configuration/devices/headless/router
            ];

            _module.args.interfaces = {
              external = "enp1s0";
              internal = "enp2s0";
              management = "enp4s0";
            };
          }];
        };

        XXLPitu-Server = lib.nixosSystem {
          system = "x86_64-linux";

          modules = [{
            imports = [
              commonModule

              self.nixosModules.profiles.headless

              self.nixosModules.profiles.zfs

              ./configuration/devices/headless/server
            ];
          }];
        };

        # Raspberry Pi 4 Model B - 8GB
        XXLPitu-Grimmjow = lib.nixosSystem {
          system = "aarch64-linux";

          modules = [{
            imports = [
              commonModule

              inputs.nixos-hardware.nixosModules.raspberry-pi-4

              self.nixosModules.profiles.headless

              ./configuration/devices/headless/raspberry-pi-4/grimmjow
            ];
          }];
        };

        # Raspberry Pi 4 Model B - 8GB
        XXLPitu-Ulquiorra = lib.nixosSystem {
          system = "aarch64-linux";

          modules = [{
            imports = [
              commonModule

              inputs.nixos-hardware.nixosModules.raspberry-pi-4

              self.nixosModules.profiles.headless

              ./configuration/devices/headless/raspberry-pi-4/ulquiorra
            ];
          }];
        };

        sdImageRaspberryPi4 = lib.nixosSystem {
          system = "aarch64-linux";

          modules = [
            {
              imports = [ "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix" ];
              sdImage.compressImage = false;
            }
            ({ public-keys, secrets, ... }: {
              imports = [
                commonModule

                inputs.nixos-hardware.nixosModules.raspberry-pi-4

                self.nixosModules.profiles.headless
              ];

              services.openssh.enable = true;

              users.users.xxlpitu = {
                extraGroups = [ "wheel" ];
                isNormalUser = true;
                password = secrets.users.xxlpitu.password;
                openssh.authorizedKeys.keys = [ public-keys.default ];
              };
            })
          ];
        };
      };

      images.sdImageRaspberryPi4 = self.nixosConfigurations.sdImageRaspberryPi4.config.system.build.image;

      deploy = lib.custom.mkDeploy {
        inherit (inputs) deploy-rs;
        inherit (self) nixosConfigurations;

        overrides = {
          Laptop = {
            hostname = "127.0.0.1";

            extraOptions = {
              autoRollback = false;
              magicRollback = false;
            };
          };

          sdImageRaspberryPi4.deploy = false;
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
        checks = import ./checks.nix {
          inherit self;
          inherit inputs;
          inherit system;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.nix-output-monitor
            pkgs.nixVersions.latest

            inputs.deploy-rs.packages.${system}.deploy-rs
          ] ++ self.checks.${system}.pre-commit.enabledPackages;

          shellHook = self.checks.${system}.pre-commit.shellHook;
        };
      });
}
