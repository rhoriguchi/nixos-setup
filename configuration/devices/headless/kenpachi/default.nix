{ secrets, ... }:
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

    # TODO remove when no more at home
    wireless = {
      enable = true;

      extraConfig = ''
        p2p_disabled=1
      '';

      networks."63466727-IoT" = secrets.wifis."63466727-IoT";
    };

    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
    ];
  };
}
