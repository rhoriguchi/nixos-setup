{ config, ... }:
let
  cfg = config.services.authelia.instances.main;
in
{
  sops.secrets.${"services/authelia/oidc/clientSecrets/jellyfin/digest"} = {
    owner = cfg.user;
    group = cfg.group;

    restartUnits = [ config.systemd.services."authelia-${cfg.name}".name ];
  };

  # https://www.authelia.com/integration/openid-connect/clients/jellyfin
  services.authelia.instances.main.settings.identity_providers.oidc = {
    authorization_policies.jellyfin = { };

    clients = [
      {
        client_id = "jellyfin";
        client_name = "Jellyfin";
        redirect_uris = [ "https://jellyfin.00a.ch/sso/OID/redirect/authelia" ];

        client_secret = "{{ secret \"${
          config.sops.secrets.${"services/authelia/oidc/clientSecrets/jellyfin/digest"}.path
        }\" }}";
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
