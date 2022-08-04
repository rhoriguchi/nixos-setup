{
  description = "My Systems flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
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

    nur-rycee = {
      url = "gitlab:rycee/nur-expressions";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, home-manager, mach-nix, nur-rycee, ... }@inputs:
    {
      nixosModules = {
        default = import ./modules;

        colors = import ./colors.nix;
        home = import ./home;
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

            ./configuration/common.nix
          ];

          nixpkgs.overlays = [ self.overlays.default ];

          _module.args = {
            inherit (self.nixosModules) colors;
            public-keys = import ./configuration/public-keys.nix;
            secrets = import ./configuration/secrets.nix;
          };
        };

        Laptop = {
          deployment.targetHost = "127.0.0.1";

          imports = [
            ./configuration/devices/laptop

            (inputs.home-manager.nixosModule)
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;

                extraSpecialArgs = {
                  inherit (self.nixosModules) colors;
                  conky = {
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

          imports = [ ./configuration/devices/headless/server ];
        };

        AdGuard = {
          deployment.targetHost = "xxlpitu-adguard";

          imports = [ ./configuration/devices/headless/raspberry-pi-4-b-8gb/adguard ];
        };

        JDH-Server = {
          deployment.targetHost = "jdh-server";

          imports = [ ./configuration/devices/headless/jdh-server ];
        };

        #####################################################

        Grimmjow = {
          deployment.targetHost = "xxlpitu-grimmjow";

          imports = [ ./configuration/devices/headless/raspberry-pi-4-b-8gb/grimmjow ];
        };

        # TODO commented
        # Ulquiorra = {
        #   deployment.targetHost = "192.168.1.128";

        #   imports = [ ./configuration/devices/headless/raspberry-pi-4-b-8gb/ulquiorra ];
        # };
      };
    } // inputs.flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import inputs.nixpkgs { inherit system; };
      in { devShells.default = pkgs.mkShell { buildInputs = [ pkgs.nix pkgs.nixopsUnstable ]; }; });
}
