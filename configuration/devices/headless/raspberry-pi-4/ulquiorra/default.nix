{ lib, secrets, ... }: {
  imports = [ ../common.nix ];

  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  networking = {
    hostName = "XXLPitu-Ulquiorra";

    interfaces.eth0 = {
      useDHCP = lib.mkForce false;

      ipv4.addresses = [{
        address = "172.16.0.1";
        prefixLength = 24;
      }];
    };

    wireless = {
      enable = true;

      networks.Niflheim = secrets.wifis.Niflheim;
    };

    nat = {
      enable = true;

      externalInterface = "wlan0";
      internalInterfaces = [ "eth0" ];

      forwardPorts = [
        {
          proto = "tcp";
          destination = "172.16.0.2";
          sourcePort = 22; # SSH
        }
        {
          proto = "tcp";
          destination = "172.16.0.2";
          sourcePort = 80; # http
        }
        {
          proto = "tcp";
          destination = "172.16.0.2";
          sourcePort = 443; # https
        }
        {
          proto = "tcp";
          destination = "172.16.0.2";
          sourcePort = 32400; # Plex
        }
        {
          proto = "udp";
          destination = "172.16.0.2";
          sourcePort = 51820; # WireGuard
        }
      ];
    };

    firewall = {
      allowedUDPPorts = [
        67 # DHCP

        51820 # WireGuard
      ];

      allowedTCPPorts = [
        22 # SSH
        80 # http
        443 # https
        32400 # Plex
      ];
    };
  };

  services = {
    dnsmasq = {
      enable = true;

      settings = {
        interface = "eth0";

        dhcp-authoritative = true;
        dhcp-range = "172.16.0.3, 172.16.0.254";
        dhcp-option = [ "option:router,172.16.0.1" "option:dns-server, 1.1.1.1, 1.0.0.1" ];

        dhcp-host = "24:5a:4c:7b:36:11, unifi, 172.16.0.2";
      };
    };

    wireguard-network = {
      enable = true;
      type = "client";
    };
  };
}
