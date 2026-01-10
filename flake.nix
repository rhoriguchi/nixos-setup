{
  description = "Systems flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";

    deploy-rs = {
      # TODO uncomment when https://github.com/serokell/deploy-rs/pull/359 merged
      # url = "github:serokell/deploy-rs";
      url = "github:szlend/deploy-rs?ref=fix-show-derivation-parsing";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    headplane = {
      url = "github:tale/headplane";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      # TODO uncomment after version > 0.53.1
      # url = "github:hyprwm/Hyprland?ref=v0.53.1";
      url = "github:hyprwm/Hyprland?rev=81e7498ec27156ee97aabba6fe4993412d98d1ab";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-github-actions = {
      url = "github:nix-community/nix-github-actions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-minecraft = {
      url = "github:Infinidoge/nix-minecraft";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixkraken = {
      url = "github:nicolas-goudry/nixkraken";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs =
    { self, ... }@inputs:
    let
      lib = inputs.nixpkgs.lib.extend self.overlays.lib;

      # Adapted from https://github.com/hmajid2301/nixicle/blob/8e8f5b1f2612a441b9f9da3e893af60774448836/lib/deploy/default.nix
      mkDeploy =
        {
          overrides ? { },
        }:
        let
          hosts = self.nixosConfigurations;
          names = lib.attrNames hosts;
        in
        {
          nodes = lib.foldl (
            result: name:
            let
              inherit (host.pkgs.stdenv.hostPlatform) system;
              host = hosts.${name};
            in
            result
            // lib.optionalAttrs (overrides.${name}.deploy or true) {
              "${name}" = {
                hostname = lib.toLower (overrides.${name}.hostname or "${name}");

                profiles.system = {
                  sshUser = "root";
                  path = inputs.deploy-rs.lib.${system}.activate.nixos host;
                }
                // (overrides.${name}.extraOptions or { });
              };
            }
          ) { } names;
        };
    in
    {
      githubActions = inputs.nix-github-actions.lib.mkGithubMatrix {
        checks =
          let
            filterAttrs =
              attrs:
              lib.filterAttrs (
                key: _:
                !(lib.elem key [
                  "deploy-activate"
                  "deploy-schema"
                ])
              ) attrs;
            removeChecks = checks: lib.mapAttrs (_: system: filterAttrs system) checks;
          in
          lib.getAttrs [ "x86_64-linux" ] (removeChecks self.checks);
      };

      nixosModules = {
        default.imports = [
          inputs.headplane.nixosModules.headplane
          inputs.hyprland.nixosModules.default
          inputs.nix-minecraft.nixosModules.minecraft-servers

          ./modules/default
        ];

        profiles = import ./modules/profiles;
        colors = import ./modules/colors.nix;

        home-manager.imports = [
          inputs.nix-index-database.homeModules.nix-index
          inputs.nixkraken.homeManagerModules.nixkraken
          ./modules/home-manager
        ];
        home-manager-gnome.imports = [ ./modules/home-manager-gnome ];
        home-manager-hyprland.imports = [
          inputs.hyprland.homeManagerModules.default
          ./modules/home-manager-hyprland
        ];
      };

      overlays = {
        default = lib.composeManyExtensions (
          [
            inputs.deploy-rs.overlays.default
            inputs.firefox-addons.overlays.default
            inputs.headplane.overlays.default
            inputs.hyprland.overlays.default
            inputs.nix-minecraft.overlay
          ]
          ++ import ./overlays
        );

        lib = (_: super: { custom = import ./lib.nix { lib = super; }; });
      };

      nixosConfigurations =
        let
          commonModule = {
            imports = [
              self.nixosModules.default

              self.nixosModules.profiles.ssh
            ];

            nix.registry.nixpkgs.flake = inputs.nixpkgs;

            nixpkgs.overlays = [ self.overlays.default ];

            _module.args = {
              inherit (self.nixosModules) colors;
              secrets = import ./secrets.nix;
            };
          };
        in
        {
          # Dell XPS 13 9350
          XXLPitu-Aizen = lib.nixosSystem {
            system = "x86_64-linux";

            modules = [
              {
                imports = [
                  commonModule

                  inputs.nixos-hardware.nixosModules.dell-xps-13-9350

                  self.nixosModules.profiles.headful
                  self.nixosModules.profiles.hyprland

                  self.nixosModules.profiles.laptop-power-management
                  self.nixosModules.profiles.podman
                  self.nixosModules.profiles.python

                  ./configuration/devices/aizen

                  inputs.home-manager.nixosModules.default
                  {
                    home-manager = {
                      useGlobalPkgs = true;
                      useUserPackages = true;

                      backupFileExtension = "backup";
                      overwriteBackup = true;

                      extraSpecialArgs = commonModule._module.args;

                      users.rhoriguchi.imports = [
                        self.nixosModules.home-manager
                        self.nixosModules.home-manager-hyprland
                      ];
                    };
                  }
                ];

                boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
              }
            ];
          };

          # GoWin R86S-N N305A
          XXLPitu-Urahara = lib.nixosSystem {
            system = "x86_64-linux";

            modules = [
              {
                imports = [
                  commonModule

                  self.nixosModules.profiles.headless

                  ./configuration/devices/headless/urahara
                ];

                _module.args.interfaces = {
                  external = "eth4";
                  internal = "eth3";
                };
              }
            ];
          };

          XXLPitu-Tier = lib.nixosSystem {
            system = "x86_64-linux";

            modules = [
              {
                imports = [
                  commonModule

                  self.nixosModules.profiles.headless

                  self.nixosModules.profiles.zfs

                  ./configuration/devices/headless/tier
                ];
              }
            ];
          };

          # Hetzner cx23
          XXLPitu-Nelliel = lib.nixosSystem {
            system = "x86_64-linux";

            modules = [
              {
                imports = [
                  commonModule

                  self.nixosModules.profiles.headless

                  ./configuration/devices/headless/nelliel
                ];
              }
            ];
          };

          # Raspberry Pi 4 Model B - 8GB
          XXLPitu-Grimmjow = lib.nixosSystem {
            system = "aarch64-linux";

            modules = [
              {
                imports = [
                  commonModule

                  inputs.nixos-hardware.nixosModules.raspberry-pi-4

                  self.nixosModules.profiles.headless

                  ./configuration/devices/headless/raspberry-pi-4/grimmjow
                ];
              }
            ];
          };

          # Raspberry Pi 4 Model B - 8GB
          XXLPitu-Ulquiorra = lib.nixosSystem {
            system = "aarch64-linux";

            modules = [
              {
                imports = [
                  commonModule

                  inputs.nixos-hardware.nixosModules.raspberry-pi-4

                  self.nixosModules.profiles.headless

                  ./configuration/devices/headless/raspberry-pi-4/ulquiorra
                ];
              }
            ];
          };
        };

      deploy = mkDeploy {
        overrides.XXLPitu-Aizen = {
          hostname = "127.0.0.1";

          extraOptions = {
            autoRollback = false;
            magicRollback = false;
          };
        };
      };
    }
    // inputs.flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [ self.overlays.default ];
        };
      in
      {
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
          ]
          ++ self.checks.${system}.pre-commit.enabledPackages;

          shellHook = self.checks.${system}.pre-commit.shellHook;
        };
      }
    );
}
