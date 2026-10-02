{ lib, ... }:
{
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  nix = {
    distributedBuilds = lib.mkForce false;

    sshServe = {
      enable = true;

      write = true;
      trusted = true;
      protocol = "ssh-ng";

      keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDlViLvbDIaywFbmErFMg4ffB/EzCN197kxAgQsrUgNu nix-ssh@XXLPitu-Aizen"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICm9NQ0sJdffZc8fV/xhrQxACqB+UmTkJHwWKmL6ECmR nix-ssh@XXLPitu-Kenpachi"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPV2D2B1IYesLsygfkhqLqCp2RBo2y8v7Eh+ECzpmt66 nix-ssh@XXLPitu-Nelliel"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINvgM2/yC4pYW4W8/sRe9iGkcyCDeDCMC19kejgG6Xab nix-ssh@XXLPitu-Ulquiorra"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFmpuHvVFRdfEKsUwE8afVwPESACQnpRwnpCXGg1jFR0 nix-ssh@XXLPitu-Urahara"
      ];
    };
  };
}
