{ pkgs ? import <nixpkgs> { overlays = import ../overlays; }, ... }:
pkgs.nixosTest {
  name = "home-assistant-test";

  nodes.machine = {
    imports = [
      ../modules/default/infomaniak.nix
      ../modules/profiles/nginx.nix

      ../configuration/devices/headless/server/home-assistant
    ];

    _module.args.secrets = {
      adguard = {
        username = "test";
        password = "password";
      };

      infomaniak = {
        username = "test";
        password = "password";
      };

      mystrom = {
        email = "test@example.com";
        password = "password";
      };

      netatmo = {
        homeId = "000000000000000000000000";
        email = "test@example.com";
        password = "password";
      };

      openWeatherMap.apiKey = "00000000000000000000000000000000";

      homeassistant = {
        latitude = 0.0;
        longitude = 0.0;
        elevation = 0;
      };

      wifis."63466727-Guest".psk = "psk";
    };
  };

  testScript = ''
    start_all()

    machine.wait_for_unit("home-assistant.service")
    machine.wait_for_unit("nginx.service")
    machine.wait_for_unit("postgresql.service")

    machine.wait_for_open_port(8123)
    machine.succeed("curl localhost:8123")
  '';
}
