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
