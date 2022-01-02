{ pkgs, ... }: {
  imports = [
    ./common.nix

    ./devices/laptop
  ];

  services.openssh.openFirewall = false;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  environment.systemPackages = [ pkgs.nixopsUnstable ];
}
