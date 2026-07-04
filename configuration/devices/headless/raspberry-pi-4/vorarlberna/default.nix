{
  imports = [
    ../common.nix

    ./kiosk.nix
  ];

  time.timeZone = "Europe/Zurich";

  networking.hostName = "XXLPitu-Vorarlberna";
}
