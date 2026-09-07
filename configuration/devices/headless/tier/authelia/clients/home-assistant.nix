{
  # https://github.com/christiaangoossens/hass-oidc-auth/blob/main/docs/provider-configurations/authelia.md
  services.authelia.instances.main.settings.identity_providers.oidc = {
    authorization_policies.home-assistant = { };

    clients = [
      {
        client_id = "home-assistant";
        client_name = "Home Assistant";
        redirect_uris = [ "https://home-assistant.00a.ch/auth/oidc/callback" ];

        public = true;
        require_pkce = true;
        pkce_challenge_method = "S256";

        scopes = [
          "openid"
          "profile"
          "groups"
        ];

        authorization_policy = "home-assistant";
      }
    ];
  };
}
