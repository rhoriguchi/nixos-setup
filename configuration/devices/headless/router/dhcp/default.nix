{ interfaces, ... }:
let
  internalInterface = interfaces.internal;

  ips = import ./ips.nix;
in
{
  networking.firewall.interfaces =
    let
      rules.allowedUDPPorts = [
        67 # DHCP
      ];
    in
    {
      "${internalInterface}" = rules;
      "${internalInterface}.2" = rules;
      "${internalInterface}.3" = rules;
      "${internalInterface}.4" = rules;
      "${internalInterface}.10" = rules;
      "${internalInterface}.100" = rules;

      br0 = rules;
    };

  services.kea.dhcp4 = {
    enable = true;

    settings = {
      lease-database = {
        type = "memfile";
        persist = true;
        name = "/var/lib/kea/dhcp4.leases";
      };

      authoritative = true;
      valid-lifetime = 60 * 60;

      interfaces-config.interfaces = [
        "${internalInterface}"
        "${internalInterface}.2"
        "${internalInterface}.3"
        "${internalInterface}.4"
        "${internalInterface}.10"
        "${internalInterface}.100"

        "br0"
      ];

      ddns-generated-prefix = "";

      subnet4 = [
        {
          id = 1;
          interface = internalInterface;
          subnet = "192.168.1.0/24";
          pools = [ { pool = "192.168.1.2 - 192.168.1.254"; } ];

          ddns-qualifying-suffix = "local";

          option-data = [
            {
              name = "routers";
              data = "192.168.1.1";
            }
            {
              name = "domain-name-servers";
              data = "192.168.1.1";
            }
            {
              name = "domain-name";
              data = "local";
            }
          ];
          reservations = [
            {
              hw-address = "74:83:c2:74:90:b7";
              ip-address = ips.cloudKey;
            }
          ];
        }
        {
          id = 2;
          interface = "${internalInterface}.2";
          subnet = "192.168.2.0/24";
          pools = [ { pool = "192.168.2.2 - 192.168.2.254"; } ];

          ddns-qualifying-suffix = "local";

          option-data = [
            {
              name = "routers";
              data = "192.168.2.1";
            }
            {
              name = "domain-name-servers";
              data = "192.168.2.1";
            }
            {
              name = "domain-name";
              data = "local";
            }
          ];
        }
        {
          id = 3;
          interface = "${internalInterface}.3";
          subnet = "192.168.3.0/24";
          pools = [ { pool = "192.168.3.2 - 192.168.3.254"; } ];

          ddns-qualifying-suffix = "local";

          option-data = [
            {
              name = "routers";
              data = "192.168.3.1";
            }
            {
              name = "domain-name-servers";
              data = "192.168.3.1";
            }
            {
              name = "domain-name";
              data = "local";
            }
          ];
          reservations = [
            {
              hw-address = "dc:a6:32:da:9d:b3";
              ip-address = ips.ulquiorra;
            }
          ];
        }
        {
          id = 4;
          interface = "${internalInterface}.4";
          subnet = "192.168.4.0/24";
          pools = [ { pool = "192.168.4.2 - 192.168.4.254"; } ];

          ddns-qualifying-suffix = "local";

          option-data = [
            {
              name = "routers";
              data = "192.168.4.1";
            }
            {
              name = "domain-name-servers";
              data = "192.168.4.1";
            }
            {
              name = "domain-name";
              data = "local";
            }
          ];
        }
        {
          id = 10;
          interface = "${internalInterface}.10";
          subnet = "192.168.10.0/24";
          pools = [ { pool = "192.168.10.2 - 192.168.10.254"; } ];

          ddns-qualifying-suffix = "local";

          option-data = [
            {
              name = "routers";
              data = "192.168.10.1";
            }
            {
              name = "domain-name-servers";
              data = "192.168.10.1";
            }
            {
              name = "domain-name";
              data = "local";
            }
          ];
          reservations = [
            {
              hw-address = "c8:7f:54:03:bd:79";
              ip-address = ips.server;
            }
          ];
        }
        {
          id = 100;
          interface = "${internalInterface}.100";
          subnet = "192.168.100.0/24";
          pools = [ { pool = "192.168.100.2 - 192.168.100.254"; } ];

          ddns-qualifying-suffix = "local";

          option-data = [
            {
              name = "routers";
              data = "192.168.100.1";
            }
            {
              name = "domain-name-servers";
              data = "192.168.100.1";
            }
            {
              name = "domain-name";
              data = "local";
            }
          ];
        }

        {
          id = 999;
          interface = "br0";
          subnet = "172.16.1.0/24";
          pools = [ { pool = "172.16.1.2 - 172.16.1.254"; } ];

          ddns-send-updates = false;

          option-data = [
            {
              name = "routers";
              data = "172.16.1.1";
            }
            {
              name = "domain-name-servers";
              data = "1.1.1.1, 1.0.0.1";
            }
          ];
        }
      ];

      loggers = [
        {
          name = "kea-dhcp4.commands";
          severity = "ERROR";
          output_options = [ { output = "stdout"; } ];
        }
      ];
    };
  };
}
