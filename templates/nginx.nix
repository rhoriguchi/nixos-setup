{
  security.acme = {
    acceptTerms = true;
    defaults.email = "mail.00a.ch";
  };

  services.nginx = {
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
  };
}
