{
  network = {
    description = "My Systems";
    enableRollback = true;
    storage.legacy = { };
  };

  defaults.imports = [ ./configuration/common.nix ];

  Laptop = { pkgs, ... }: {
    deployment.targetHost = "127.0.0.1";

    imports = [ ./configuration/devices/laptop ];

    services.openssh.openFirewall = false;

    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

    environment.systemPackages = [ pkgs.nixopsUnstable ];
  };

  Server = { ... }: {
    deployment.targetHost = "xxlpitu-home.duckdns.org";

    imports = [ ./configuration/devices/headless/server ];
  };

  JDH-Server = { ... }: {
    deployment.targetHost = "jcrk.synology.me";

    imports = [ ./configuration/devices/headless/jdh-server ];
  };

  AdGuard = { ... }: {
    deployment.targetHost = "xxlpitu-adguard";

    imports = [ ./configuration/devices/headless/raspberry-pi-4-b-8gb/adguard ];
  };

  Rain-Town = { ... }: {
    deployment.targetHost = "xxlpitu-rain-town.duckdns.org";

    imports = [ ./configuration/devices/headless/raspberry-pi-4-b-8gb/rain-town ];
  };

  Horgen = { ... }: {
    deployment = {
      targetHost = "xxlpitu-horgen.duckdns.org";
      targetPort = 1234;
    };

    imports = [ ./configuration/devices/headless/raspberry-pi-4-b-8gb/horgen ];
  };
}
