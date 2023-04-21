{ pkgs ? import <nixpkgs> { overlays = import ../overlays; }, ... }:
pkgs.nixosTest {
  name = "adguardhome-test";

  nodes.machine = {
    imports = [
      ../modules/profiles/nginx.nix

      ../configuration/devices/headless/raspberry-pi-4-b-8gb/adguard/adguardhome.nix
    ];

    _module.args.secrets = import ../secrets.nix;
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
