{
  network = {
    description = "My Systems";
    enableRollback = true;
  };

  defaults.imports = [ ./configuration/common.nix ./configuration/secrets.nix ];

  Laptop = { pkgs, ... }: {
    deployment.targetHost = "localhost";

    imports = [ ./configuration/devices/laptop ];

    services.openssh.openFirewall = false;

    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  };

  XXLPitu-Home = { ... }: {
    deployment.targetHost = "xxlpitu-home.duckdns.org";

    imports = [ ./configuration/devices/servers/server-home ];
  };

  XXLPitu-Rain-Town = { ... }: {
    deployment.targetHost = "xxlpitu-rain-town.duckdns.org";

    imports =
      [ ./configuration/devices/servers/raspberry-pi-4-b-8gb-rain-town ];

    nixpkgs.system = "aarch64-linux";
  };

  # TODO commented
  # XXLPitu-Horgen = { ... }: {
  #   # TODO use correct values
  #   # deployment = {
  #   #   targetHost = "xxlpitu-horgen.duckdns.org";
  #   #   targetPort = 1234;
  #   # };

  #   deployment.targetHost = "192.168.2.130";

  #   imports = [ ./configuration/devices/servers/raspberry-pi-3-b-plus-horgen ];

  #   nixpkgs.system = "aarch64-linux";
  # };
}
