{ config, lib, ... }:
let
  cfg = config.services.nginx.stream;
in
{
  options.services.nginx.stream = {
    resolvers = lib.mkOption {
      type = lib.types.listOf lib.types.nonEmptyStr;
      default = [ ];
    };
    upstreams = lib.mkOption {
      default = { };
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            server = lib.mkOption { type = lib.types.nonEmptyStr; };
            hostnames = lib.mkOption {
              type = lib.types.listOf lib.types.nonEmptyStr;
              default = [ ];
            };
          };
        }
      );
    };
  };

  config = lib.mkIf (config.services.nginx.enable && lib.attrNames cfg.upstreams != [ ]) {
    services.nginx = {
      defaultSSLListenPort = 9443;

      streamConfig = ''
        ${lib.optionalString (cfg.resolvers != [ ]) "resolver ${lib.concatStringsSep " " cfg.resolvers};"}

        ${lib.pipe cfg.upstreams [
          (lib.mapAttrsToList (
            key: value: ''
              upstream ${key} {
                server ${value.server};
              }
            ''
          ))

          (lib.concatStringsSep "\n")
        ]}

        map $ssl_preread_server_name $upstream {
          # indicates that source values can be hostnames with a prefix or suffix mask:
          hostnames;

          ${lib.pipe cfg.upstreams [
            (lib.mapAttrsToList (
              key: value:
              lib.pipe value.hostnames [
                (map (host: "${host} ${key};"))
                (lib.concatStringsSep "\n")
              ]
            ))

            (lib.concatStringsSep "\n")
          ]}
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
