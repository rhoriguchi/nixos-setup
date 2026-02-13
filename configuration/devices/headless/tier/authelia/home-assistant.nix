{
  # https://github.com/christiaangoossens/hass-oidc-auth/blob/main/docs/provider-configurations/authelia.md
  services.authelia.instances.main.settings.identity_providers.oidc.clients = [
    {
      client_id = "home-assistant";
      client_name = "Home Assistant";
      public = true;
      require_pkce = true;
      pkce_challenge_method = "S256";
      authorization_policy = "one_factor";
      redirect_uris = [ "https://home-assistant.00a.ch/auth/oidc/callback" ];
      scopes = [
        "openid"
        "profile"
        "groups"
      ];
      id_token_signed_response_alg = "RS256";
    }
  ];
}
