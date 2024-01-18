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

  outputs = { self, nixpkgs, flake-utils, firefox-addons, home-manager, nix-minecraft, nix-index-database, nixos-hardware, pre-commit-hooks
    , spicetify-nix, ... }@inputs:
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
        inputs.nix-minecraft.overlay

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
          imports = [ self.nixosModules.default ];

          nixpkgs.overlays = [ self.overlays.default ];

          nix.nixPath = [ "nixpkgs=${nixpkgs}" ];

          _module.args = {
            inherit (self.nixosModules) colors;
            public-keys = import ./configuration/public-keys.nix;
            secrets = import ./secrets.nix;
          };
        };

        # Lenovo Legion 5 15ACH6
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
              nixpkgs = {
                overlays = [ self.overlays.default ];

                # TODO required for obsidian
                config.permittedInsecurePackages = [ "electron-25.9.0" ];
              };

              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;

                extraSpecialArgs.colors = self.nixosModules.colors;

                users.rhoriguchi = self.nixosModules.home-manager;
              };
            }
          ];

          services.openssh.openFirewall = false;

          boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
        };

        Server = {
          deployment.targetHost = "home.00a.ch";

          imports = [
            self.nixosModules.profiles.headless

            self.nixosModules.profiles.zfs

            ./configuration/devices/headless/server
          ];
        };

        # Raspberry Pi 4 Model B - 8GB
        Grimmjow = {
          deployment.targetHost = "xxlpitu-grimmjow";

          imports = [
            inputs.nixos-hardware.nixosModules.raspberry-pi-4

            self.nixosModules.profiles.headless

            ./configuration/devices/headless/raspberry-pi-4/grimmjow
          ];
        };

        # Raspberry Pi 4 Model B - 8GB
        Ulquiorra = {
          deployment.targetHost = "xxlpitu-ulquiorra";

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
          config = {
            allowUnfree = true;

            # TODO fix for deprecated nixops
            permittedInsecurePackages = [
              # CVE-2023-32681
              "python3.10-requests-2.29.0"

              # CVE-2023-2650
              # CVE-2023-2975
              # CVE-2023-3446
              # CVE-2023-3817
              # CVE-2023-38325
              "python3.10-cryptography-40.0.2"
            ];
          };
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
              markdownlint.enable = true;
              nixfmt = {
                enable = true;
                excludes = [ "secrets\\.nix" ];
              };
            };

            settings = {
              markdownlint.config.MD013 = false;
              nixfmt.width = 140;
            };
          };
        } // (import ./checks { inherit pkgs; });

        devShells.default = pkgs.mkShell {
          buildInputs = [ pkgs.nixVersions.unstable (pkgs.nixopsUnstable.withPlugins (_: [ ])) ];
          shellHook = self.checks.${system}.pre-commit.shellHook;
        };
      });
}
