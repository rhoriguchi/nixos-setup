{
  services.home-assistant.config.homeassistant.auth_providers = [
    { type = "homeassistant"; }
    {
      type = "trusted_networks";
      allow_bypass_login = true;
      trusted_networks = [ "192.168.100.0/24" ];
      trusted_users."192.168.100.0/24" = [ "9100570ba3a249fe9178ecac34786b08" ];
    }
  ];
}
