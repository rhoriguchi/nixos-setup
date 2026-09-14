{ config, ... }:
let
  cfg = config.services.authelia.instances.main;
in
{
  sops.secrets.${"services/authelia/oidc/clientSecrets/mealie/digest"} = {
    owner = cfg.user;
    group = cfg.group;

    restartUnits = [ config.systemd.services."authelia-${cfg.name}".name ];
  };

  # https://www.authelia.com/integration/openid-connect/clients/mealie
  services.authelia.instances.main.settings.identity_providers.oidc = {
    authorization_policies.mealie = { };

    clients = [
      {
        client_id = "mealie";
        client_name = "Mealie";
        redirect_uris = [ "https://mealie.00a.ch/login" ];

        client_secret = "{{ secret \"${
          config.sops.secrets.${"services/authelia/oidc/clientSecrets/mealie/digest"}.path
        }\" }}";
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
