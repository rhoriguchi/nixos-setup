{
  lib,
  pkgs,
  secrets,
  ...
}:
{
  services = {
    unpoller = {
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

    netdata.configDir."go.d/snmp.conf" = (pkgs.formats.yaml { }).generate "snmp.conf" {
      jobs = [
        {
          name = "Cloud Key Gen.2";
          hostname = "unifi.local";
          community = "public";
          options.version = 2;
        }
      ]
      ++
        map
          (name: {
            inherit name;
            hostname = lib.toLower "${lib.replaceStrings [ " " ] [ "" ] name}.local";
            community = "public";
            options.version = 2;
          })
          [
            "Guest room - U7 Pro"
            "Living room - U6 LR"
            "Living room - US 8 60W"
            "Network closet - USW Pro XG 8 PoE"
            "Office - US 8 PoE 150W"
          ];
    };
  };
}
