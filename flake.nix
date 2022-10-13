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
  };

  outputs = { self, nixpkgs, flake-utils, home-manager, mach-nix, nixos-hardware, nur-rycee, ... }@inputs:
    {
      nixosModules = {
        default = import ./modules;

        colors = import ./colors.nix;
        home = import ./home;
        templates = import ./templates;
      };

      overlays.default = inputs.nixpkgs.lib.composeManyExtensions ([
        (self: super:
          let nur-rycee = import inputs.nur-rycee { pkgs = super; };
          in {
            mach-nix = inputs.mach-nix.lib.${super.stdenv.hostPlatform.system};

            inherit (nur-rycee) firefox-addons;
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

            self.nixosModules.templates.flakes
            self.nixosModules.templates.i18n
            self.nixosModules.templates.keyboard
            self.nixosModules.templates.nano
            self.nixosModules.templates.nix
            self.nixosModules.templates.zsh

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

            self.nixosModules.templates.displaylink
            self.nixosModules.templates.git
            self.nixosModules.templates.gnome
            self.nixosModules.templates.hidpi
            self.nixosModules.templates.java
            self.nixosModules.templates.javascript
            self.nixosModules.templates.kotlin
            self.nixosModules.templates.podman
            self.nixosModules.templates.power-management
            self.nixosModules.templates.printing
            self.nixosModules.templates.python
            self.nixosModules.templates.terminal
            self.nixosModules.templates.util

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
            self.nixosModules.templates.doas
            self.nixosModules.templates.docker
            self.nixosModules.templates.fancy-motd
            self.nixosModules.templates.nginx
            self.nixosModules.templates.util

            ./configuration/devices/headless/server
          ];
        };

        AdGuard = {
          deployment.targetHost = "xxlpitu-adguard";

          imports = [
            inputs.nixos-hardware.nixosModules.raspberry-pi-4

            self.nixosModules.templates.doas
            self.nixosModules.templates.fancy-motd
            self.nixosModules.templates.nginx
            self.nixosModules.templates.util

            ./configuration/devices/headless/raspberry-pi-4-b-8gb/adguard
          ];
        };

        JDH-Server = {
          deployment.targetHost = "jdh-server";

          imports = [
            self.nixosModules.templates.doas
            self.nixosModules.templates.fancy-motd
            self.nixosModules.templates.nginx
            self.nixosModules.templates.util

            ./configuration/devices/headless/jdh-server
          ];
        };

        #####################################################

        Grimmjow = {
          deployment.targetHost = "xxlpitu-grimmjow";

          imports = [
            inputs.nixos-hardware.nixosModules.raspberry-pi-4

            self.nixosModules.templates.doas
            self.nixosModules.templates.fancy-motd
            self.nixosModules.templates.nginx
            self.nixosModules.templates.util

            ./configuration/devices/headless/raspberry-pi-4-b-8gb/grimmjow
          ];
        };

        Ulquiorra = {
          deployment.targetHost = "xxlpitu-ulquiorra";

          imports = [
            inputs.nixos-hardware.nixosModules.raspberry-pi-4

            self.nixosModules.templates.doas
            self.nixosModules.templates.fancy-motd
            self.nixosModules.templates.nginx
            self.nixosModules.templates.util

            ./configuration/devices/headless/raspberry-pi-4-b-8gb/ulquiorra
          ];
        };
      };
    } // inputs.flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import inputs.nixpkgs { inherit system; };
      in { devShells.default = pkgs.mkShell { buildInputs = [ pkgs.nix pkgs.nixopsUnstable ]; }; });
}
