{ secrets, ... }: {
  services.wlsunset = {
    enable = true;

    latitude = secrets.location.latitude;
    longitude = secrets.location.longitude;

    temperature = {
      day = 10000;
      night = 3700;
    };
  };
}
