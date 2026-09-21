{
  nix = {
    sshServe = {
      enable = true;

      write = true;
      trusted = true;
      protocol = "ssh-ng";

      keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDlViLvbDIaywFbmErFMg4ffB/EzCN197kxAgQsrUgNu nix-ssh@XXLPitu-Aizen"
      ];
    };

    daemonCPUSchedPolicy = "idle";
    daemonIOSchedClass = "idle";
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
}
