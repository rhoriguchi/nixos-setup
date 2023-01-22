{ lib, pkgs, public-keys, ... }: {
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

  networking.useDHCP = false;

  time.timeZone = "Europe/Zurich";

  services.openssh = {
    enable = true;

    settings = {
      KbdInteractiveAuthentication = false;
      PasswordAuthentication = false;
    };
  };

  users = {
    mutableUsers = false;

    users.root = {
      hashedPassword = "*";
      openssh.authorizedKeys.keys = [ public-keys.default ];
    };
  };
}
