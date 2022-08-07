{ lib, pkgs, public-keys, ... }: {
  imports = [ ./configs/flake.nix ./configs/i18n.nix ./configs/keyboard.nix ./configs/nano.nix ./configs/nix.nix ./configs/zsh.nix ];

  # TODO upgrade to 5.19 once zfs supports it
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_5_18;

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
      openssh.authorizedKeys.keys = [ public-keys.default ];
    };
  };
}
