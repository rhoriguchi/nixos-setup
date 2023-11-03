{ pkgs ? import <nixpkgs> { overlays = import ../overlays; }, ... }:
pkgs.nixosTest {
  name = "adguardhome-test";

  nodes.machine = {
    imports = [
      ../modules/profiles/nginx.nix

      ../configuration/devices/headless/raspberry-pi-4-b-8gb/adguard/adguardhome.nix
    ];

    _module.args.secrets.adguard = {
      username = "test";
      encryptedUsernamePassword = "$2y$05$gjHEFr9yo.y/8a8DV5jGievJzKzE2IhxPibxmg4QbE3H8mIfVRxbu"; # test:password
    };
  };

  testScript = ''
    start_all()

    machine.wait_for_unit("adguardhome.service")
    machine.wait_for_unit("nginx.service")

    machine.wait_for_open_port(53)
    machine.wait_for_open_port(80)
    machine.succeed("curl localhost:80")
  '';
}
