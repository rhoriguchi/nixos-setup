{
  networking.timeServers = [
    "0.pool.ntp.org"
    "time.cloudflare.com"
    "time.nist.gov"
  ];

  services.chrony.enable = true;
}
