{
  imports = [
    ../common.nix

    ./pykvm.nix
  ];

  time.timeZone = "Europe/Zurich";

  networking.hostName = "XXLPitu-Unohana";
}
