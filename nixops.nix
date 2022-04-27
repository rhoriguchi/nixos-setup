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

  AdGuard = { ... }: {
    deployment.targetHost = "xxlpitu-adguard";

    imports = [ ./configuration/devices/headless/raspberry-pi-4-b-8gb/adguard ];
  };

  JDH-Server = { ... }: {
    deployment.targetHost = "jdh-server";

    imports = [ ./configuration/devices/headless/jdh-server ];
  };

  ######################################################################

  Horgen = { ... }: {
    deployment.targetHost = "xxlpitu-horgen";

    imports = [ ./configuration/devices/headless/raspberry-pi-4-b-8gb/horgen ];
  };

  Placeholder = { ... }: {
    deployment.targetHost = "xxlpitu-placeholder";

    imports = [ ./configuration/devices/headless/raspberry-pi-4-b-8gb/placeholder ];
  };
}
