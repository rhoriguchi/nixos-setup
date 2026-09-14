{ config, lib, ... }:
let
  tunnelId = "3406e183-7f28-49aa-b3ca-54154886a314";
in
{
  sops.secrets = {
    "services/cloudflared/tunnels/${tunnelId}/accountTag" = { };
    "services/cloudflared/tunnels/${tunnelId}/tunnelSecret" = { };
  };

  sops.templates."services.cloudflared.tunnels.${tunnelId}.credentialsFile" = {
    content = lib.toJSON {
      AccountTag = config.sops.placeholder."services/cloudflared/tunnels/${tunnelId}/accountTag";
      TunnelSecret = config.sops.placeholder."services/cloudflared/tunnels/${tunnelId}/tunnelSecret";
      TunnelID = tunnelId;
    };

    restartUnits = [ config.systemd.services."cloudflared-tunnel-${tunnelId}".name ];
  };

  services.cloudflared = {
    enable = true;

    tunnels.${tunnelId} = {
      credentialsFile =
        config.sops.templates."services.cloudflared.tunnels.${tunnelId}.credentialsFile".path;

      ingress = {
        "tvtracktime.com" = "http://127.0.0.1:${toString config.services.nginx.defaultHTTPListenPort}";
        "www.tvtracktime.com" = "http://127.0.0.1:${toString config.services.nginx.defaultHTTPListenPort}";
      };

      default = "http_status:404";
    };
  };
}
