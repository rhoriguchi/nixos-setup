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

    imports = [ ./configuration/devices/servers/server ];
  };

  Rain-Town = { ... }: {
    deployment.targetHost = "xxlpitu-rain-town.duckdns.org";

    imports = [ ./configuration/devices/servers/raspberry-pi-4-b-8gb/rain-town ];

    nixpkgs.system = "aarch64-linux";
  };
}
