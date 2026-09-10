{ secrets, ... }:
{
  # https://www.authelia.com/integration/openid-connect/clients/mealie
  services.authelia.instances.main.settings.identity_providers.oidc = {
    authorization_policies.mealie = { };

    clients = [
      {
        client_id = "mealie";
        client_name = "Mealie";
        redirect_uris = [ "https://mealie.00a.ch/login" ];

        client_secret = secrets.authelia.oidcClientSecrets.mealie.digest;
        token_endpoint_auth_method = "client_secret_basic";

        require_pkce = true;
        pkce_challenge_method = "S256";

        access_token_signed_response_alg = "none";
        userinfo_signed_response_alg = "none";

        scopes = [
          "openid"
          "profile"
          "groups"
          "email"
        ];

        authorization_policy = "mealie";
      }
    ];
  };
}
