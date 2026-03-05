{
  config,
  interfaces,
  lib,
  pkgs,
  ...
}:
let
  externalInterface = interfaces.external;
  internalInterface = interfaces.internal;

  internalInterfaces = lib.filter (interface: lib.hasPrefix internalInterface interface) (
    lib.attrNames config.networking.interfaces
  );
in
{
  systemd.tmpfiles.rules = [
    "d /run/ntopng 0550 ntopng ntopng"
    "d /run/ntopng/geoip 0550 ntopng ntopng"
    "L+ /run/ntopng/geoip/GeoLite2-Country.mmdb - - - - ${pkgs.dbip-country-lite}/share/dbip/dbip-country-lite.mmdb"
  ];

  services = {
    ntopng = {
      enable = true;

      # TODO this should also allow an ip range so you can set `127.0.0.1`
      # --http-port 127.0.0.1:3050
      httpPort = 3050;

      interfaces = [ externalInterface ] ++ internalInterfaces;

      extraConfig = lib.concatStringsSep "\n" [
        "--disable-login 1"
        "--disable-autologout"

        # TODO does not work
        "--geoip-dir /run/ntopng/geoip"

        "--local-networks ${
          lib.concatStringsSep "," [
            # RFC1918
            "10.0.0.0/8"
            "172.16.0.0/12"
            "192.168.0.0/16"

            # RFC4193
            "fc00::/7"
          ]
        }"

        # "--local-networks ${
        #   let
        #     staticInterfaces = lib.filterAttrs (_: value: value.useDHCP != true) config.networking.interfaces;

        #     localNetsList = lib.flatten (
        #       lib.mapAttrsToList (
        #         key: value:
        #         map (address: "${key}=${address.address}/${toString address.prefixLength}") value.ipv4.addresses
        #       ) staticInterfaces
        #     );
        #   in
        #   lib.concatStringsSep "," localNetsList
        # }"
      ];
    };

    # nginx = {
    #   enable = true;

    #   virtualHosts."ntopng.00a.ch" = {
    #     enableACME = true;
    #     acmeRoot = null;
    #     forceSSL = true;

    #     extraConfig = ''
    #       include /run/nginx-authelia/location.conf;
    #     '';

    #     locations."/" = {
    #       proxyPass = "http://127.0.0.1:${toString config.services.ntopng.httpPort}";

    #       proxyWebsockets = true;

    #       extraConfig = ''
    #         proxy_buffering off;

    #         include /run/nginx-authelia/auth.conf;
    #       '';
    #     };
    #   };
    # };

    # infomaniak = {
    #   enable = true;

    #   username = secrets.infomaniak.username;
    #   password = secrets.infomaniak.password;
    #   hostnames = [
    #     "ntopng.00a.ch"
    #   ];
    # };
  };
}
