{
  network = {
    description = "My Systems";
    enableRollback = true;
  };

  defaults.imports = [ ./configuration/common.nix ];

  Laptop = { pkgs, ... }: {
    deployment.targetHost = "127.0.0.1";

    imports = [ ./configuration/devices/laptop ];

    services.openssh.openFirewall = false;

    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

    environment.systemPackages = [ pkgs.nixops ];
  };

  Server = { ... }: {
    deployment.targetHost = "xxlpitu-server.duckdns.org";

    imports = [ ./configuration/devices/headless/server ];
  };

  AdGuard = { ... }: {
    deployment.targetHost = "xxlpitu-adguard";

    imports = [ ./configuration/devices/headless/raspberry-pi-4-b-8gb/adguard ];

    nixpkgs.system = "aarch64-linux";
  };

  Rain-Town = { ... }: {
    deployment.targetHost = "xxlpitu-rain-town.duckdns.org";

    imports = [ ./configuration/devices/headless/raspberry-pi-4-b-8gb/rain-town ];

    nixpkgs.system = "aarch64-linux";
  };

  Horgen = { ... }: {
    deployment = {
      targetHost = "xxlpitu-horgen.duckdns.org";
      targetPort = 1234;
    };

    imports = [ ./configuration/devices/headless/raspberry-pi-4-b-8gb/horgen ];

    nixpkgs.system = "aarch64-linux";
  };
}
