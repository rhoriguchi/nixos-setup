{ secrets, ... }:
{
  # https://www.authelia.com/integration/openid-connect/clients/grafana
  services.authelia.instances.main.settings.identity_providers.oidc = {
    authorization_policies.grafana = {
      default_policy = "deny";

      rules = [
        {
          policy = "one_factor";
          subject = [
            "group:admin"
            "group:grafana"
          ];
        }
      ];
    };

    clients = [
      {
        client_id = "grafana";
        client_name = "Grafana";
        redirect_uris = [ "https://grafana.00a.ch/login/generic_oauth" ];

        client_secret = secrets.authelia.oidcClientSecrets.grafana.digest;
        token_endpoint_auth_method = "client_secret_post";

        scopes = [
          "openid"
          "profile"
          "groups"
          "email"
        ];

        authorization_policy = "grafana";
      }
    ];
  };
}
