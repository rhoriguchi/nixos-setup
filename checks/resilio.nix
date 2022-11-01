{ pkgs ? import <nixpkgs> { config.allowUnfree = true; }, ... }:
pkgs.nixosTest {
  name = "resilio-test";

  nodes = {
    machine = {
      imports = [ ../modules/default/resilio.nix ];

      services.resilio = {
        enable = true;

        syncPath = "/tmp/resilio";
      };
    };
  };

  testScript = ''
    start_all()

    machine.wait_for_unit("resilio.service")
  '';
}
