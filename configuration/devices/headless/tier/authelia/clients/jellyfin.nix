{ secrets, ... }:
{
  # https://www.authelia.com/integration/openid-connect/clients/jellyfin
  services.authelia.instances.main.settings.identity_providers.oidc = {
    authorization_policies.jellyfin = {
      default_policy = "deny";

      rules = [
        {
          policy = "one_factor";
          subject = [
            "group:admin"
            "group:jellyfin"
          ];
        }
      ];
    };

    clients = [
      {
        client_id = "jellyfin";
        client_name = "Jellyfin";
        redirect_uris = [ "https://jellyfin.00a.ch/sso/OID/redirect/authelia" ];

        client_secret = secrets.authelia.oidcClientSecrets.jellyfin.digest;
        token_endpoint_auth_method = "client_secret_post";

        scopes = [
          "openid"
          "profile"
          "groups"
        ];

        authorization_policy = "jellyfin";
      }
    ];
  };
}
