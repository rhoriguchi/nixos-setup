{
  description = "Systems flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";

    declarative-jellyfin = {
      url = "github:Sveske-Juice/declarative-jellyfin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dns = {
      url = "github:kirelagin/dns.nix";
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

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland?ref=v0.56.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";

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

    nixos-raspberrypi = {
      url = "github:nvmd/nixos-raspberrypi";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, ... }@inputs:
    let
      lib = inputs.nixpkgs.lib;

      libCustom = import ./lib.nix { inherit lib; };
      libDns = inputs.dns.lib;

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

      mkPkgs =
        args:
        import inputs.nixpkgs (
          lib.recursiveUpdate (lib.removeAttrs args [ "overlays" ]) {
            config = {
              allowUnfree = true;
              nvidia.acceptLicense = true;
            };
            overlays = [ self.overlays.default ] ++ (args.overlays or [ ]);
          }
        );
    in
    {
      lib = libCustom;

      githubActions = inputs.nix-github-actions.lib.mkGithubMatrix {
        checks = lib.pipe self.checks [
          (lib.mapAttrs (
            _: system:
            lib.filterAttrs (
              key: _:
              !(lib.elem key [
                "deploy-activate"
                "deploy-schema"
              ])
            ) system
          ))

          (lib.getAttrs [ "x86_64-linux" ])
        ];
      };

      nixosModules = {
        default.imports = [
          inputs.declarative-jellyfin.nixosModules.default
          inputs.hyprland.nixosModules.default
          inputs.nix-flatpak.nixosModules.nix-flatpak
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
            # TODO review once resolve https://github.com/hyprwm/Hyprland/discussions/14532
            inputs.hyprland.overlays.default
            inputs.hyprland.overlays.hyprland-packages
            inputs.llm-agents.overlays.shared-nixpkgs
            inputs.nix-minecraft.overlay
          ]
          ++ import ./overlays
        );
      };

      nixosConfigurations =
        let
          specialArgs = {
            inherit libCustom libDns;
            inherit (self.nixosModules) colors;
            secrets = import ./secrets.nix;
          };

          commonModule = {
            imports = [
              self.nixosModules.default

              self.nixosModules.profiles.ssh
            ];

            nix.registry.nixpkgs.flake = inputs.nixpkgs;

            nixpkgs.overlays = [ self.overlays.default ];
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
                  self.nixosModules.profiles.java
                  self.nixosModules.profiles.laptop-power-management
                  self.nixosModules.profiles.podman
                  self.nixosModules.profiles.python
                  self.nixosModules.profiles.syncthing

                  ./configuration/devices/aizen

                  inputs.home-manager.nixosModules.default
                  {
                    home-manager = {
                      useGlobalPkgs = true;
                      useUserPackages = true;

                      backupFileExtension = "backup";
                      overwriteBackup = true;

                      extraSpecialArgs = specialArgs;

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

            inherit specialArgs;
          };

          # GoWin R86S-N N305A
          XXLPitu-Urahara = lib.nixosSystem {
            system = "x86_64-linux";

            modules = [
              {
                imports = [
                  commonModule

                  self.nixosModules.profiles.headless

                  self.nixosModules.profiles.tailscale-exit-node

                  ./configuration/devices/headless/urahara
                ];

                _module.args.interfaces = {
                  external = "eth4";
                  internal = "eth3";
                };
              }
            ];

            inherit specialArgs;
          };

          XXLPitu-Tier = lib.nixosSystem {
            system = "x86_64-linux";

            modules = [
              {
                imports = [
                  commonModule

                  self.nixosModules.profiles.headless

                  self.nixosModules.profiles.syncthing
                  self.nixosModules.profiles.zfs

                  ./configuration/devices/headless/tier
                ];
              }
            ];

            inherit specialArgs;
          };

          # Hetzner CX23
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

            inherit specialArgs;
          };

          # Dell Wyse 5070 (N11D)
          XXLPitu-Kenpachi = lib.nixosSystem {
            system = "x86_64-linux";

            modules = [
              {
                imports = [
                  commonModule

                  self.nixosModules.profiles.headless

                  self.nixosModules.profiles.syncthing

                  ./configuration/devices/headless/kenpachi
                ];
              }
            ];

            inherit specialArgs;
          };

          # Raspberry Pi 4 Model B - 8GB
          XXLPitu-Ulquiorra = inputs.nixos-raspberrypi.lib.nixosSystem {
            # nixos-raspberrypi
            trustCaches = false;

            system = "aarch64-linux";

            modules = [
              {
                imports = [
                  commonModule

                  inputs.nixos-raspberrypi.nixosModules.raspberry-pi-4.base

                  self.nixosModules.profiles.headless

                  ./configuration/devices/headless/raspberry-pi-4/ulquiorra
                ];

                # Cross-compile the kernel, while using emulation/cache for the rest
                boot.kernelPackages =
                  (mkPkgs {
                    localSystem = "x86_64-linux";
                    crossSystem = "aarch64-linux";
                    overlays = [
                      inputs.nixos-raspberrypi.overlays.vendor-kernel
                      inputs.nixos-raspberrypi.overlays.vendor-firmware
                      inputs.nixos-raspberrypi.overlays.kernel-and-firmware
                    ];
                  }).linuxPackages_rpi4;
              }
            ];

            specialArgs = specialArgs // {
              inherit (inputs) nixos-raspberrypi;
            };
          };

          XXLPitu-Vorarlberna = inputs.nixos-raspberrypi.lib.nixosSystem {
            # nixos-raspberrypi
            trustCaches = false;

            system = "aarch64-linux";

            modules = [
              {
                imports = [
                  commonModule

                  inputs.nixos-raspberrypi.nixosModules.raspberry-pi-4.base

                  self.nixosModules.profiles.headless

                  ./configuration/devices/headless/raspberry-pi-4/vorarlberna
                ];

                # Cross-compile the kernel, while using emulation/cache for the rest
                boot.kernelPackages =
                  (mkPkgs {
                    localSystem = "x86_64-linux";
                    crossSystem = "aarch64-linux";
                    overlays = [
                      inputs.nixos-raspberrypi.overlays.vendor-kernel
                      inputs.nixos-raspberrypi.overlays.vendor-firmware
                      inputs.nixos-raspberrypi.overlays.kernel-and-firmware
                    ];
                  }).linuxPackages_rpi4;
              }
            ];

            specialArgs = specialArgs // {
              inherit (inputs) nixos-raspberrypi;
            };
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
        pkgs = mkPkgs {
          inherit system;
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
