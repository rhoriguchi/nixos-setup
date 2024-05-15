{
  security.acme = {
    acceptTerms = true;
    defaults.email = "contact@00a.ch";
  };

  services.nginx = {
    recommendedBrotliSettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedZstdSettings = true;
  };
}
