{
  imports = [
    ../common.nix

    ./hardware-configuration.nix
  ];

  time.timeZone = "Europe/Zurich";

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
