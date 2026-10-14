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
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIoiH7ocr3O2shucdZ/10t0I+nDfDkBEMCLewcRzYVHe nix-ssh@XXLPitu-Aizen"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPGrlLqCEsFi3QOaBwFEEfaGH4cwG2bw4qvggRrU2B// nix-ssh@XXLPitu-Kenpachi"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL894uDJtooyxhVgVUFGMbFC7DnepjwALflgqdqLDN54 nix-ssh@XXLPitu-Nelliel"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBzjtyK5C41Ck27B1a5hGEK4MV4Fztbrc9Zwfdgabjbm nix-ssh@XXLPitu-Ulquiorra"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILXCuitX8TQ4/ZfN5G6YyVsTVdqh+PLRgCFhwewgJs1I nix-ssh@XXLPitu-Urahara"
      ];
    };
  };
}
