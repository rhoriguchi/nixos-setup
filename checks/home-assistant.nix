{ pkgs ? import <nixpkgs> { overlays = import ../overlays; } }:
pkgs.nixosTest {
  name = "home-assistant.nix";

  nodes.machine = {
    imports = [
      ../modules/default/infomaniak.nix
      ../modules/profiles/nginx.nix

      ../configuration/devices/headless/server/home-assistant
    ];

    _module.args.secrets = import ../secrets.nix;
  };

  testScript = ''
    start_all()

    machine.wait_for_unit("home-assistant.service")
    machine.wait_for_unit("postgresql.service")

    machine.wait_for_open_port(8123)
    machine.succeed("curl localhost:8123")
  '';
}
