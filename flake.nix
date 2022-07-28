{
  description = "My Systems flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils, ... }:
    let pkgsFor = system: import nixpkgs { inherit system; };
    in {
      nixopsConfigurations.default = {
        inherit nixpkgs;

        network = {
          description = "My Systems";
          enableRollback = true;
          storage.legacy = { };
        };

        defaults = {
          imports = [ ./configuration/common.nix ];

          _module.args = {
            authorized-keys = import ./configuration/authorized-keys.nix;
            colors = import ./configuration/colors.nix;
            secrets = import ./configuration/secrets.nix;
          };
        };

        # TODO extract devices to network.nix https://releases.nixos.org/nixops/nixops-1.3.1/manual/manual.html#idm140737318969936

        ###################### Devices ######################

        Laptop = {
          deployment.targetHost = "127.0.0.1";

          imports = [ ./configuration/devices/laptop ];

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

        Horgen = {
          deployment.targetHost = "xxlpitu-grimmjow";

          imports = [ ./configuration/devices/headless/raspberry-pi-4-b-8gb/grimmjow ];
        };

        Placeholder = {
          deployment.targetHost = "192.168.1.128";

          imports = [ ./configuration/devices/headless/raspberry-pi-4-b-8gb/ulquiorra ];
        };
      };
    } // utils.lib.eachDefaultSystem
    (system: let pkgs = pkgsFor system; in { devShell = pkgs.mkShell { buildInputs = [ pkgs.nix pkgs.nixopsUnstable ]; }; });
}
