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

  ######################################################################

  Server = { ... }: {
    deployment.targetHost = "home.00a.ch";

    imports = [ ./configuration/devices/headless/server ];
  };

  JDH-Server = { ... }: {
    deployment.targetHost = "jcrk.synology.me";

    imports = [ ./configuration/devices/headless/jdh-server ];
  };

  ######################################################################

  AdGuard = { ... }: {
    deployment.targetHost = "xxlpitu-adguard";

    imports = [ ./configuration/devices/headless/raspberry-pi-4-b-8gb/adguard ];
  };

  Horgen = { ... }: {
    deployment = {
      targetHost = "horgen.00a.ch";
      targetPort = 1234;
    };

    imports = [ ./configuration/devices/headless/raspberry-pi-4-b-8gb/horgen ];
  };
}
