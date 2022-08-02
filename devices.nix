{
  Laptop = {
    deployment.targetHost = "127.0.0.1";

    imports = [ ./configuration/devices/laptop ];

    services.openssh.openFirewall = false;

    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  };

  #####################################################

  Server = {
    deployment.targetHost = "home.00a.ch";

    imports = [ ./configuration/devices/headless/server ];
  };

  AdGuard = {
    deployment.targetHost = "xxlpitu-adguard";

    imports = [ ./configuration/devices/headless/raspberry-pi-4-b-8gb/adguard ];
  };

  JDH-Server = {
    deployment.targetHost = "jdh-server";

    imports = [ ./configuration/devices/headless/jdh-server ];
  };

  #####################################################

  Grimmjow = {
    deployment.targetHost = "xxlpitu-grimmjow";

    imports = [ ./configuration/devices/headless/raspberry-pi-4-b-8gb/grimmjow ];
  };

  # TODO commented
  # Placeholder = {
  #   deployment.targetHost = "192.168.1.128";

  #   imports = [ ./configuration/devices/headless/raspberry-pi-4-b-8gb/ulquiorra ];
  # };
}
