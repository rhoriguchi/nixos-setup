{ lib, config, pkgs, ... }:
let
  cfg = config.services.pi-hole;

  version = "v5.8.1";
in {
  options.services.pi-hole = {
    enable = lib.mkEnableOption "Pi-hole";
    password = lib.mkOption { type = lib.types.str; };
    serverIp = lib.mkOption { type = lib.types.str; };
    webUIPort = lib.mkOption {
      default = 80;
      type = lib.types.port;
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers.pi-hole = {
      image = "pihole/pihole:${version}";

      environment = {
        PIHOLE_DNS_ = builtins.concatStringsSep ";" [ "1.1.1.1" "1.0.0.1" ];
        ServerIP = cfg.serverIp;
        TEMPERATUREUNIT = "c";
        TZ = config.time.timeZone;
        WEBPASSWORD = cfg.password;
      };

      ports = [
        "53:53"
        "53:53/udp"
        # TODO PI-HOLE not needed?
        # "67:67/udp"
        "${cfg.webUIPort}:80"
      ];

      volumes = [ "/var/lib/pihole:/etc/pihole" "/var/lib/dnsmasq.d:/etc/dnsmasq.d" ];

      extraOptions = [
        # TODO PI-HOLE not needed?
        # "--cap-add=NET_ADMIN"
        "--dns=127.0.0.1"
      ];
    };

    # TODO PI-HOLE use Nginx for https

    networking.firewall = {
      allowedTCPPorts = [ 53 cfg.webUIPort ];
      allowedUDPPorts = [ 53 ];
    };
  };
}
