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
      package = pkgs.nginx.override {
        modules = [
          pkgs.nginxModules.moreheaders
        ];
      };

      recommendedBrotliSettings = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      recommendedUwsgiSettings = true;

      commonHttpConfig = ''
        more_set_headers Referrer-Policy origin-when-cross-origin;
        more_set_headers X-Content-Type-Options nosniff;
        more_set_headers X-Frame-Options DENY;
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
  };
}
