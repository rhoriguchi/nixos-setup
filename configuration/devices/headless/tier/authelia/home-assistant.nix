{
  # https://github.com/christiaangoossens/hass-oidc-auth/blob/main/docs/provider-configurations/authelia.md
  services.authelia.instances.main.settings.identity_providers.oidc = {
    authorization_policies.home-assistant = {
      default_policy = "deny";

      rules = [
        {
          policy = "one_factor";
          subject = [
            "group:admin"

            "group:home-assistant"
          ];
        }
      ];
    };

    clients = [
      {
        client_id = "home-assistant";
        client_name = "Home Assistant";
        public = true;
        require_pkce = true;
        pkce_challenge_method = "S256";
        redirect_uris = [ "https://home-assistant.00a.ch/auth/oidc/callback" ];
        scopes = [
          "openid"
          "profile"
          "groups"
        ];
        id_token_signed_response_alg = "RS256";

        authorization_policy = "home-assistant";
      }
    ];
  };
}
