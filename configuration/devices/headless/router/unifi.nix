{ pkgs, secrets, ... }: {
  services.unpoller = {
    enable = true;

    unifi.defaults = {
      user = "unifipoller";
      pass = pkgs.writeText "unifipoller-password" secrets.unpoller.users.unifipoller.password;

      url = "https://unifi.local";
      verify_ssl = false;
    };

    influxdb.disable = true;

    prometheus.http_listen = "127.0.0.1:9130";
  };
}
