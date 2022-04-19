{
  imports = [ ../common.nix ./hardware-configuration.nix ];

  networking.hostName = "XXLPitu-Horgen";

  services = {
    infomaniak = {
      enable = true;

      username = (import ../../../../secrets.nix).services.infomaniak.username;
      password = (import ../../../../secrets.nix).services.infomaniak.password;
      hostnames = [ "horgen.00a.ch" ];
    };

    resilio = {
      enable = true;

      secrets = (import ../../../../secrets.nix).services.resilio.secrets;
      syncPath = "/mnt/Data/Sync";
    };
  };
}
