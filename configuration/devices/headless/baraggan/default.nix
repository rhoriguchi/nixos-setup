{ secrets, ... }:
{
  imports = [
    ../common.nix

    # TODO update
    ./hardware-configuration.nix
  ];

  networking = {
    hostName = "XXLPitu-Baraggan";

    interfaces.enp1s0.useDHCP = true;

    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
    ];
  };

  services.resilio = {
    enable = true;

    secrets = secrets.resilio.secrets;
    syncPath = "/var/lib/Sync";
  };
}
