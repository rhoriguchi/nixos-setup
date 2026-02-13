{ pkgs, ... }:
{
  services.home-assistant = {
    customComponents = [ pkgs.home-assistant-custom-components.auth_oidc ];

    config = {
      homeassistant.auth_providers = [
        { type = "homeassistant"; }
        {
          type = "trusted_networks";
          allow_bypass_login = true;
          trusted_networks = [ "192.168.100.0/24" ];
          trusted_users."192.168.100.0/24" = [ "9100570ba3a249fe9178ecac34786b08" ];
        }
      ];

      auth_oidc = {
        client_id = "home-assistant";
        discovery_url = "https://authelia.00a.ch/.well-known/openid-configuration";
        display_name = "Authelia";

        roles.admin = "admin";

        features.automatic_person_creation = true;
      };
    };
  };
}
