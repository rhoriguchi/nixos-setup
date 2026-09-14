{ config, ... }:
let
  cfg = config.services.authelia.instances.main;
in
{
  sops.secrets.${"services/authelia/oidc/clientSecrets/grafana/digest"} = {
    owner = cfg.user;
    group = cfg.group;

    restartUnits = [ config.systemd.services."authelia-${cfg.name}".name ];
  };

  # https://www.authelia.com/integration/openid-connect/clients/grafana
  services.authelia.instances.main.settings.identity_providers.oidc = {
    authorization_policies.grafana = { };

    clients = [
      {
        client_id = "grafana";
        client_name = "Grafana";
        redirect_uris = [ "https://grafana.00a.ch/login/generic_oauth" ];

        client_secret = "{{ secret \"${
          config.sops.secrets.${"services/authelia/oidc/clientSecrets/grafana/digest"}.path
        }\" }}";
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
