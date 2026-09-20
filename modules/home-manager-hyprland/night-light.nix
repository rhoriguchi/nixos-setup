{ osConfig, ... }:
{
  services.gammastep = {
    enable = true;

    tray = true;
    provider = if osConfig.services.geoclue2.enable then "geoclue2" else "manual";

    temperature = {
      day = 10000;
      night = 3700;
    };
  };
}
