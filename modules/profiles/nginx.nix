{ pkgs, secrets, ... }:
{
  security.acme = {
    acceptTerms = true;

    defaults = {
      email = "contact@00a.ch";

      # https://go-acme.github.io/lego/dns/infomaniak
      dnsProvider = "infomaniak";
      credentialFiles.INFOMANIAK_ACCESS_TOKEN_FILE = pkgs.writeText "infomaniak_access_token" secrets.infomaniak.accessToken;

      dnsPropagationCheck = false;
    };
  };

  services = {
    nginx = {
      recommendedBrotliSettings = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      recommendedUwsgiSettings = true;

      commonHttpConfig = ''
        add_header Referrer-Policy origin-when-cross-origin;
        add_header X-Content-Type-Options nosniff;
        add_header X-Frame-Options DENY;
      '';

      virtualHosts."_" = {
        default = true;
        rejectSSL = true;

        locations = {
          "@blackhole".return = 444;

          "/" = {
            return = 444;

            extraConfig = ''
              error_page 400 = @blackhole;
            '';
          };
        };
      };
    };

    logrotate.settings.nginx.enable = false;
  };
}
