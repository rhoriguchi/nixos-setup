{ pkgs ? import <nixpkgs> {
  config.allowUnfree = true;
  overlays = import ../overlays;
}, ... }:
pkgs.nixosTest {
  name = "adguardhome-test";

  nodes.machine = { lib, ... }: {
    imports = [
      ../modules/default

      ../modules/profiles/nginx.nix
      ../configuration/devices/headless/router/adguardhome.nix
    ];

    networking.firewall.enable = false;

    services = {
      infomaniak.enable = lib.mkForce false;
      dnsmasq.settings.port = 9053;
    };

    _module.args.secrets = {
      infomaniak = {
        username = "test";
        password = "password";
      };

      nginx.basicAuth."adguardhome.00a.ch".test = "password";
    };
  };

  testScript = ''
    start_all()

    machine.wait_for_unit("adguardhome.service")
    machine.wait_for_unit("nginx.service")

    machine.wait_for_open_port(53)
    machine.wait_for_open_port(80)
    machine.succeed("curl 127.0.0.1:80")
  '';
}
