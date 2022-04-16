{ lib, config, pkgs, ... }: {
  imports = [
    ./modules

    ./configs/i18n.nix
    ./configs/keyboard.nix
    ./configs/nano.nix
    ./configs/nix.nix
  ];

  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_5_17;

  networking.useDHCP = false;

  time.timeZone = "Europe/Zurich";

  services.openssh = {
    enable = true;

    kbdInteractiveAuthentication = false;
    passwordAuthentication = false;
  };

  programs.zsh.enable = true;

  users = {
    defaultUserShell = pkgs.zsh;
    mutableUsers = false;

    users.root = {
      hashedPassword = "*";
      openssh.authorizedKeys.keys = import ./authorized-keys.nix;
    };
  };

  environment.shellAliases = {
    l = null;
    ll = null;
  };
}
