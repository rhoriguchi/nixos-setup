{ secrets, ... }: {
  imports = [
    ../common.nix

    # TODO update
    ./hardware-configuration.nix
  ];

  networking = {
    hostName = "XXLPitu-Nelliel";

    # TODO uncomment
    # interfaces.eth0.useDHCP = true;

    nameservers = [ "1.1.1.1" "1.0.0.1" ];
  };

  services.resilio = {
    enable = true;

    secrets = secrets.resilio.secrets;
    syncPath = "/var/lib/Sync";
  };
}
