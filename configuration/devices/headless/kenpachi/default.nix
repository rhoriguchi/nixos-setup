{
  imports = [
    ../common.nix

    ./hardware-configuration.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = "XXLPitu-Kenpachi";

    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
    ];
  };

  services.custom-syncthing.bandwidthLimit.upload = 15 * 1024;
}
