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
    let inherit (inputs.nixpkgs) lib;
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

      overlays.default = lib.composeManyExtensions ([
        inputs.deploy-rs.overlays.default
        inputs.nix-minecraft.overlay

        (_: super: {
          borg-exporter-image = inputs.borg-exporter.defaultPackage.${super.system};
          firefox-addons = inputs.firefox-addons.packages.${super.system};
        })
      ] ++ import ./overlays);

      nixosConfigurations = let
        commonModule = {
          imports = [ self.nixosModules.default ];

          system.configurationRevision = self.rev or self.dirtyRev or null;

          nixpkgs.overlays = [ self.overlays.default ];

          _module.args = {
            inherit (self.nixosModules) colors;
            public-keys = import ./configuration/public-keys.nix;
            secrets = import ./secrets.nix;
          };
        };
      in {
        Laptop = inputs.nixpkgs.lib.nixosSystem {
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
            ];

            boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
          }];
        };

        Router = inputs.nixpkgs.lib.nixosSystem {
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

        Server = inputs.nixpkgs.lib.nixosSystem {
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

        Grimmjow = inputs.nixpkgs.lib.nixosSystem {
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

        Ulquiorra = inputs.nixpkgs.lib.nixosSystem {
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
      };

      homeConfigurations."rhoriguchi" = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux";

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
      };

      deploy.nodes = {
        # Lenovo Legion 5 15ACH6
        Laptop = {
          hostname = "127.0.0.1";

          profilesOrder = [ "system" "rhoriguchi-home-manager" ];

          autoRollback = false;
          magicRollback = false;

          profiles = {
            system = {
              sshUser = "root";

              path = inputs.deploy-rs.lib."x86_64-linux".activate.nixos self.nixosConfigurations.Laptop;
            };

            rhoriguchi-home-manager = {
              sshUser = "root";
              user = "rhoriguchi";

              path = inputs.deploy-rs.lib."x86_64-linux".activate.home-manager self.homeConfigurations."rhoriguchi";
            };
          };
        };

        Router = {
          hostname = "xxlpitu-router";

          profiles.system = {
            sshUser = "root";

            path = inputs.deploy-rs.lib."x86_64-linux".activate.nixos self.nixosConfigurations.Router;
          };
        };

        Server = {
          hostname = "xxlpitu-server";

          profiles.system = {
            sshUser = "root";

            path = inputs.deploy-rs.lib."x86_64-linux".activate.nixos self.nixosConfigurations.Server;
          };
        };

        # Raspberry Pi 4 Model B - 8GB
        Grimmjow = {
          hostname = "xxlpitu-grimmjow";

          profiles.system = {
            sshUser = "root";

            path = inputs.deploy-rs.lib."aarch64-linux".activate.nixos self.nixosConfigurations.Grimmjow;
          };
        };

        # Raspberry Pi 4 Model B - 8GB
        Ulquiorra = {
          hostname = "xxlpitu-ulquiorra";

          profiles.system = {
            sshUser = "root";

            path = inputs.deploy-rs.lib."aarch64-linux".activate.nixos self.nixosConfigurations.Ulquiorra;
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
          pre-commit = inputs.git-hooks.lib.${system}.run {
            src = ./.;

            addGcRoot = true;

            hooks = {
              actionlint.enable = true;
              check-case-conflicts.enable = true;
              check-executables-have-shebangs.enable = true;
              check-merge-conflicts.enable = true;
              check-shebang-scripts-are-executable.enable = true;
              check-symlinks.enable = true;
              deadnix = {
                enable = true;
                excludes = [ "hardware-configuration\\.nix$" ];
              };
              end-of-file-fixer = {
                enable = true;
                excludes = [ "secrets\\.nix$" ];
              };
              fix-byte-order-marker.enable = true;
              markdownlint = {
                enable = true;

                settings.configuration.MD013 = false;
              };
              mixed-line-endings = {
                enable = true;
                excludes = [ "secrets\\.nix$" ];
              };
              nixfmt-classic = {
                enable = true;
                excludes = [ "secrets\\.nix$" ];

                settings.width = 140;
              };
              trim-trailing-whitespace = {
                enable = true;
                excludes = [ "secrets\\.nix$" ];
              };
            };
          };
        } // (inputs.deploy-rs.lib.${system}.deployChecks self.deploy);

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
