{ secrets, ... }: {
  imports = [ ../common.nix ];

  networking = {
    hostName = "XXLPitu-Nelliel";

    nameservers = [ "1.1.1.1" "1.0.0.1" ];
  };

  services.resilio = {
    enable = true;
    logging.enable = false;

    secrets = secrets.resilio.secrets;
    syncPath = "/var/lib/Sync";
  };
}
