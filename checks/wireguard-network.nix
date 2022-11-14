{ pkgs ? import <nixpkgs> { overlays = import ../overlays; }, ... }:
let
  inherit (pkgs) lib;

  routerAddress = "192.168.3.1";
  serverAddress = "192.168.3.2";
  clientAddress = "192.168.3.3";

  defaultConfig = { ... }: {
    imports = [ ../modules/default/infomaniak.nix ../modules/default/wireguard-network ];

    networking = {
      defaultGateway = routerAddress;
      interfaces.eth0.ipv4.addresses = [ ];
    };

    services.wireguard-network.enable = true;
  };

  ips = import ../modules/default/wireguard-network/ips.nix;
  secrets = import ../modules/default/wireguard-network/secrets.nix;

  keyToUnitName = publicKey:
    let replaced = lib.replaceStrings [ "/" "-" " " "+" "=" ] [ "-" "\\x2d" "\\x20" "\\x2b" "\\x3d" ] publicKey;
    in lib.replaceStrings [ "\\" ] [ "\\\\" ] replaced;
  getUnitName = publicKey: isServer: "wireguard-wg0-peer-${keyToUnitName publicKey}${lib.optionalString (!isServer) "-refresh"}.service";
  getServerUnitName = publicKey: getUnitName publicKey true;
  getClientUnitName = publicKey: getUnitName publicKey false;
in pkgs.nixosTest {
  name = "wireguard-network-test";

  nodes = {
    router = {
      virtualisation.vlans = [ 1 2 ];

      networking = {
        nat = {
          enable = true;

          internalInterfaces = [ "eth1" ];
        };

        firewall.trustedInterfaces = [ "eth1" ];

        interfaces = {
          eth0.ipv4.addresses = [ ];

          eth1.ipv4.addresses = [{
            address = routerAddress;
            prefixLength = 24;
          }];
        };
      };
    };

    server = {
      imports = [ defaultConfig ];

      virtualisation.vlans = [ 1 ];

      networking.interfaces.eth1.ipv4.addresses = [{
        address = serverAddress;
        prefixLength = 24;
      }];

      services = {
        infomaniak = {
          enable = true;

          username = "username";
          password = "password";
        };

        wireguard-network.type = "server";
      };
    };

    # TODO get hostname dynamically and use everywhere
    AdGuard = {
      imports = [ defaultConfig ];

      virtualisation.vlans = [ 2 ];

      networking.interfaces.eth1.ipv4.addresses = [{
        address = clientAddress;
        prefixLength = 24;
      }];

      networking.hosts.${serverAddress} = [ "wireguard.00a.ch" ];

      services.wireguard-network.type = "client";
    };
  };

  testScript = ''
    start_all()

    server.wait_for_unit("${getServerUnitName secrets.AdGuard.public}")
    AdGuard.wait_for_unit("${getClientUnitName secrets.server.public}")

    server.fail("ping -c1 ${clientAddress}")
    AdGuard.fail("ping -c1 ${serverAddress}")

    server.succeed("ping -c1 ${ips.AdGuard}")
    AdGuard.succeed("ping -c1 ${ips.server}")
  '';
}
