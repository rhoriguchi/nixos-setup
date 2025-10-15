{ secrets, ... }:
{
  services.wlsunset = {
    enable = true;

    latitude = secrets.home.latitude;
    longitude = secrets.home.longitude;

    temperature = {
      day = 10000;
      night = 3700;
    };
  };
}
