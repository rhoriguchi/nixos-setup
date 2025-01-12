{
  description = "Systems flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";

    borg-exporter = {
      url = "git+https://codeberg.org/k0ral/borg-exporter.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    colmena = {
      url = "github:zhaofengli/colmena";
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
      githubActions =
        inputs.nix-github-actions.lib.mkGithubMatrix { checks = lib.getAttrs [ inputs.flake-utils.lib.system.x86_64-linux ] self.checks; };

      nixosModules = {
        default.imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ./modules/default ];

        profiles = import ./modules/profiles;
        colors = import ./modules/colors.nix;
        home-manager.imports = [ inputs.nix-index-database.hmModules.nix-index ./modules/home-manager ];
      };

      overlays.default = lib.composeManyExtensions ([
        inputs.colmena.overlays.default
        inputs.nix-minecraft.overlay

        (_: super: {
          borg-exporter-image = inputs.borg-exporter.defaultPackage.${super.system};
          firefox-addons = inputs.firefox-addons.packages.${super.system};
        })
      ] ++ import ./overlays);

      # https://github.com/zhaofengli/colmena/pull/228
      colmenaHive = inputs.colmena.lib.makeHive self.colmena;

      colmena = {
        meta.nixpkgs = import inputs.nixpkgs { system = inputs.flake-utils.lib.system.x86_64-linux; };

        defaults = {
          imports = [ self.nixosModules.default ];

          system.configurationRevision = self.rev or self.dirtyRev or null;

          nixpkgs.overlays = [ self.overlays.default ];

          _module.args = {
            inherit (self.nixosModules) colors;
            public-keys = import ./configuration/public-keys.nix;
            secrets = import ./secrets.nix;
          };
        };

        # Lenovo Legion 5 15ACH6
        Laptop = {
          deployment = {
            targetHost = "127.0.0.1";

            tags = [ "headful" inputs.flake-utils.lib.system.x86_64-linux ];
          };

          imports = [
            inputs.nixos-hardware.nixosModules.lenovo-legion-15ach6

            self.nixosModules.profiles.headful

            self.nixosModules.profiles.colmena
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
              nixpkgs.overlays = [ self.overlays.default ];

              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;

                extraSpecialArgs.colors = self.nixosModules.colors;

                users.rhoriguchi = self.nixosModules.home-manager;
              };
            }
          ];

          boot.binfmt.emulatedSystems = [ inputs.flake-utils.lib.system.aarch64-linux ];
        };

        Router = {
          deployment = {
            targetHost = null;
            allowLocalDeployment = true;

            tags = [ "headless" inputs.flake-utils.lib.system.x86_64-linux ];
          };

          imports = [
            self.nixosModules.profiles.headless

            ./configuration/devices/headless/router
          ];

          _module.args.interfaces = {
            external = "enp1s0";
            internal = "enp2s0";
            management = "enp4s0";
          };
        };

        Server = {
          deployment = {
            targetHost = "xxlpitu-server";

            tags = [ "headless" inputs.flake-utils.lib.system.x86_64-linux ];
          };

          imports = [
            self.nixosModules.profiles.headless

            self.nixosModules.profiles.zfs

            ./configuration/devices/headless/server
          ];
        };

        # Raspberry Pi 4 Model B - 8GB
        Grimmjow = {
          nixpkgs.system = inputs.flake-utils.lib.system.aarch64-linux;

          deployment = {
            targetHost = "xxlpitu-grimmjow";

            tags = [ "headless" "raspberry-pi-4" inputs.flake-utils.lib.system.aarch64-linux ];
          };

          imports = [
            inputs.nixos-hardware.nixosModules.raspberry-pi-4

            self.nixosModules.profiles.headless

            ./configuration/devices/headless/raspberry-pi-4/grimmjow
          ];
        };

        # Raspberry Pi 4 Model B - 8GB
        Ulquiorra = {
          nixpkgs.system = inputs.flake-utils.lib.system.aarch64-linux;

          deployment = {
            targetHost = "xxlpitu-ulquiorra";

            tags = [ "headless" "raspberry-pi-4" inputs.flake-utils.lib.system.aarch64-linux ];
          };

          imports = [
            inputs.nixos-hardware.nixosModules.raspberry-pi-4

            self.nixosModules.profiles.headless

            ./configuration/devices/headless/raspberry-pi-4/ulquiorra
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
        checks.pre-commit = inputs.git-hooks.lib.${system}.run {
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

        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.nix-output-monitor
            pkgs.nixVersions.latest

            inputs.colmena.packages.${system}.colmena
          ] ++ self.checks.${system}.pre-commit.enabledPackages;
          shellHook = self.checks.${system}.pre-commit.shellHook;
        };
      });
}
