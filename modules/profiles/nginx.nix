{
  security.acme = {
    acceptTerms = true;
    defaults.email = "contact@00a.ch";
  };

  services.nginx = {
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
  };
}
