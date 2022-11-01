{ pkgs ? import <nixpkgs> { overlays = import ../overlays; }, ... }:
pkgs.nixosTest {
  name = "adguardhome-test";

  nodes.machine.services.adguardhome = {
    enable = true;

    settings.dns = {
      bind_host = "127.0.0.1";
      bootstrap_dns = [ "tls://1.1.1.1" "tls://1.0.0.1" ];
    };
  };

  testScript = ''
    start_all()

    machine.wait_for_unit("adguardhome.service")

    machine.wait_for_open_port(3000)
    machine.succeed("curl localhost:3000")
  '';
}
