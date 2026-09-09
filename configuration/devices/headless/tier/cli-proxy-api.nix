{ secrets, ... }:
{
  # > ssh -L 54545:localhost:54545 root@xxlpitu-tier
  # > sudo -u cli-proxy-api cli-proxy-api --config /etc/cli-proxy-api/config.yaml --claude-login --no-browser

  services.cli-proxy-api = {
    enable = true;

    apiKeys = [ secrets.cli-proxy-api.api-key ];
  };
}
