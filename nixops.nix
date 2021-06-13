{
  network = {
    description = "My Systems";
    enableRollback = true;
  };

  defaults.imports = [ ./configuration/common.nix ];

  Laptop = { pkgs, ... }: {
    deployment.targetHost = "localhost";

    imports = [ ./configuration/devices/laptop ];

    services.openssh.openFirewall = false;

    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

    environment.systemPackages = [ pkgs.nixops ];
  };

  Server = { ... }: {
    deployment.targetHost = "xxlpitu-server.duckdns.org";

    imports = [ ./configuration/devices/headless/server ];
  };

  Pi-Hole = { ... }: {
    deployment.targetHost = "xxlpitu-pi-hole";

    imports = [ ./configuration/devices/headless/raspberry-pi-4-b-8gb/pi-hole ];

    nixpkgs.system = "aarch64-linux";
  };

  Rain-Town = { ... }: {
    deployment.targetHost = "xxlpitu-rain-town.duckdns.org";

    imports = [ ./configuration/devices/headless/raspberry-pi-4-b-8gb/rain-town ];

    nixpkgs.system = "aarch64-linux";
  };
}
