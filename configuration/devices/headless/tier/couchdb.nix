{
  config,
  lib,
  pkgs,
  secrets,
  ...
}:
let
  databases = [ "obsidian" ];
in
{
  # TODO make sure monitoring works for multiple dbs https://www.netdata.cloud/integrations/data-collection/databases/couchdb
  # > go.d.plugin -c /etc/netdata/conf.d -d -m couchdb

  services = {
    couchdb = {
      enable = true;

      adminPass = secrets.couchdb.users.admin.password;

      extraConfig = {
        chttpd = {
          authentication_handlers = lib.concatStringsSep ", " [
            "{chttpd_auth, proxy_authentication_handler}"
            "{chttpd_auth, default_authentication_handler}"
          ];

          require_valid_user = true;

          # 4 * 2^30 => 4 GB
          max_http_request_size = 4294967296;
        };

        chttpd_auth.proxy_use_secret = false;

        # 50 * 2^20 => 50 MB
        couchdb.max_document_size = 52428800;
      };
    };

    infomaniak = {
      enable = true;

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
      hostnames = [
        "couchdb.00a.ch"
      ];
    };

    nginx = {
      enable = true;

      commonHttpConfig = ''
        map $http_origin $couchdb_cors_origin {
          default "";
          ${lib.concatStringsSep " " (
            map (database: ''"app://${database}.md" "app://${database}.md";'') databases
          )}
          "capacitor://localhost" "capacitor://localhost"; "http://localhost" "http://localhost";
        }
      '';

      virtualHosts."couchdb.00a.ch" = {
        enableACME = true;
        acmeRoot = null;
        forceSSL = true;

        extraConfig = ''
          include /run/nginx-authelia/location.conf;

          client_max_body_size ${toString config.services.couchdb.extraConfig.chttpd.max_http_request_size};

          proxy_buffering off;
          proxy_request_buffering off;

          # Clear Auth headers to prevent bypass
          more_clear_input_headers X-Auth-CouchDB-UserName;
          more_clear_input_headers X-Auth-CouchDB-Roles;
          more_clear_input_headers X-Auth-CouchDB-Token;
        '';

        locations = {
          "/".return = "302 /_utils";

          # TODO figure fauxton and auto login
          # https://couchdb.apache.org/fauxton-visual-guide/index.html
          # https://docs.couchdb.org/en/stable/api/server/authn.html
          # TODO web sockets needed?
          "/_utils" = {
            proxyPass = "http://127.0.0.1:${toString config.services.couchdb.port}/_utils";
            extraConfig = ''
              include /run/nginx-authelia/auth.conf;

              proxy_set_header X-Auth-CouchDB-UserName ${config.services.couchdb.adminUser};
            '';
          };
        }
        // (lib.listToAttrs (
          map (
            database:
            lib.nameValuePair "/${database}" {
              proxyPass = "http://127.0.0.1:${toString config.services.couchdb.port}/${database}";

              extraConfig = ''
                more_set_headers WWW-Authenticate 'Basic realm="couchdb"';

                more_set_headers Access-Control-Allow-Origin $couchdb_cors_origin;
                more_set_headers Access-Control-Allow-Credentials true;
                more_set_headers Access-Control-Allow-Methods "GET, POST, OPTIONS, PUT, DELETE, HEAD";
                more_set_headers Access-Control-Allow-Headers "Authorization, Content-Type, *";

                if ($request_method = 'OPTIONS') {
                  return 204;
                }
              '';
            }
          ) databases
        ));
      };
    };
  };

  systemd.services = lib.listToAttrs (
    map (
      database:
      lib.nameValuePair "couchdb-init-${database}" {
        enable = config.services.couchdb.enable;

        wants = [ config.systemd.services.couchdb.name ];
        after = [ config.systemd.services.couchdb.name ];
        wantedBy = [ "multi-user.target" ];

        script = ''
          until ${pkgs.curl}/bin/curl -s http://127.0.0.1:${toString config.services.couchdb.port}/ > /dev/null; do
            sleep 1
          done

          status=$(${pkgs.curl}/bin/curl -s -o /dev/null -w "%{http_code}" -u "admin:${config.services.couchdb.adminPass}" http://127.0.0.1:${toString config.services.couchdb.port}/${database})
          if [ "$status" -eq 404 ]; then
            ${pkgs.curl}/bin/curl -X PUT -u "${database}:${
              secrets.couchdb.users.${database}.password
            }" http://127.0.0.1:${toString config.services.couchdb.port}/${database}
          fi
        '';

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
      }
    ) databases
  );
}
