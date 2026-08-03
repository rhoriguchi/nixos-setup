{
  config,
  pkgs,
  secrets,
  ...
}:
let
  tunnelId = "3406e183-7f28-49aa-b3ca-54154886a314";
in
{
  services.cloudflared = {
    enable = true;

    tunnels.${tunnelId} = {
      credentialsFile = pkgs.writers.writeJSON "${tunnelId}.json" {
        AccountTag = "${secrets.cloudflared.tunnels.${tunnelId}.accountTag}";
        TunnelSecret = "${secrets.cloudflared.tunnels.${tunnelId}.tunnelSecret}";
        TunnelID = tunnelId;
      };

      ingress = {
        "tvtracktime.com" = "http://127.0.0.1:${toString config.services.nginx.defaultHTTPListenPort}";
        "www.tvtracktime.com" = "http://127.0.0.1:${toString config.services.nginx.defaultHTTPListenPort}";
      };

      default = "http_status:404";
    };
  };
}
