{ lib, pkgs, public-keys, ... }: {
  # TODO unpin when zfs works
  boot.kernelPackages = lib.mkDefault pkgs.linuxKernel.packages.linux_6_6;
  # boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

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
