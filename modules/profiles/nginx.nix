{
  security.acme = {
    acceptTerms = true;
    defaults.email = "contact@00a.ch";
  };

  services = {
    nginx = {
      recommendedBrotliSettings = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      recommendedZstdSettings = true;

      appendHttpConfig = ''
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
