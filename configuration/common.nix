{ lib, config, pkgs, ... }: {
  imports = [
    ./modules

    ./configs/i18n.nix
    ./configs/keyboard.nix
    ./configs/nano.nix
    ./configs/nix.nix
    ./configs/zsh.nix
  ];

  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_5_17;

  networking.useDHCP = false;

  time.timeZone = "Europe/Zurich";

  services.openssh = {
    enable = true;

    kbdInteractiveAuthentication = false;
    passwordAuthentication = false;
  };

  users = {
    mutableUsers = false;

    users.root = {
      hashedPassword = "*";
      openssh.authorizedKeys.keys = import ./authorized-keys.nix;
    };
  };
}
