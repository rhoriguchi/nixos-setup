{ config, lib, ... }:
let cfg = config.services.nginx.stream;
in {
  options.services.nginx.stream = {
    resolvers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
    upstreams = lib.mkOption {
      default = { };
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          server = lib.mkOption { type = lib.types.str; };
          hostnames = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
          };
        };
      });
    };
  };

  config = lib.mkIf (config.services.nginx.enable && (lib.length (lib.attrNames cfg.upstreams) > 0)) {
    services.nginx = {
      defaultSSLListenPort = 9443;

      streamConfig = ''
        ${lib.optionalString (lib.length cfg.resolvers > 0) "resolver ${lib.concatStringsSep " " cfg.resolvers};"}

        ${lib.concatStringsSep "\n" (lib.mapAttrsToList (key: value: ''
          upstream ${key} {
            server ${value.server};
          }
        '') cfg.upstreams)}

        map $ssl_preread_server_name $upstream {
          # indicates that source values can be hostnames with a prefix or suffix mask:
          hostnames;

          ${
            lib.concatStringsSep "\n"
            (lib.mapAttrsToList (key: value: lib.concatStringsSep "\n" (map (host: "${host} ${key};") value.hostnames)) cfg.upstreams)
          }
        }

        server {
          listen 443;
          ${lib.optionalString config.networking.enableIPv6 "listen [::]:443;"}

          ssl_preread on;

          proxy_pass $upstream;
        }
      '';
    };
  };
}
