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

          # 4 * 2^30 = 4 GB
          max_http_request_size = 4294967296;
        };

        chttpd_auth.proxy_use_secret = false;

        # 50 * 2^20 = 50 MB
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
          "app://obsidian.md" "app://obsidian.md";
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
          more_clear_input_headers 'X-Auth-CouchDB-UserName';
          more_clear_input_headers 'X-Auth-CouchDB-Roles';
          more_clear_input_headers 'X-Auth-CouchDB-Token';
        '';

        locations = {
          "= /" = {
            proxyPass = "http://127.0.0.1:${toString config.services.couchdb.port}/_utils/";
            extraConfig = ''
              include /run/nginx-authelia/auth.conf;

              proxy_set_header X-Auth-CouchDB-UserName admin;
              proxy_set_header X-Auth-CouchDB-Roles _admin;
            '';
          };

          "/" = {
            proxyPass = "http://127.0.0.1:${toString config.services.couchdb.port}";
            extraConfig = ''
              include /run/nginx-authelia/auth.conf;

              proxy_set_header X-Auth-CouchDB-UserName admin;
              proxy_set_header X-Auth-CouchDB-Roles _admin;
            '';
          };

          "/dashboard.assets/" = {
            proxyPass = "http://127.0.0.1:${toString config.services.couchdb.port}/_utils/dashboard.assets/";
            extraConfig = ''
              include /run/nginx-authelia/auth.conf;

              proxy_set_header X-Auth-CouchDB-UserName admin;
              proxy_set_header X-Auth-CouchDB-Roles _admin;
            '';
          };

          "/sync/obsidian" = {
            proxyPass = "http://127.0.0.1:${toString config.services.couchdb.port}/obsidian";

            extraConfig = ''
              more_set_headers 'WWW-Authenticate: Basic realm="couchdb"';

              more_set_headers 'Access-Control-Allow-Origin: $couchdb_cors_origin';
              more_set_headers 'Access-Control-Allow-Credentials: true';
              more_set_headers 'Access-Control-Allow-Methods: GET, POST, OPTIONS, PUT, DELETE, HEAD';
              more_set_headers 'Access-Control-Allow-Headers: Authorization, Content-Type, *';

              if ($request_method = 'OPTIONS') {
                return 204;
              }
            '';
          };
        };
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

          admin_auth="admin:${config.services.couchdb.adminPass}"
          base="http://127.0.0.1:${toString config.services.couchdb.port}"

          # PUT on an already-existing db/user/doc is a harmless no-op (curl
          # without -f exits 0 on non-2xx too), so these are safe to run
          # unconditionally instead of checking existence first.
          ${pkgs.curl}/bin/curl -s -X PUT -u "$admin_auth" "$base/_users" > /dev/null
          ${pkgs.curl}/bin/curl -s -X PUT -u "$admin_auth" "$base/${database}" > /dev/null
          ${pkgs.curl}/bin/curl -s -X PUT -u "$admin_auth" \
            -H "Content-Type: application/json" \
            -d '{"name":"${database}","password":"${
              secrets.couchdb.users.${database}.password
            }","roles":[],"type":"user"}' \
            "$base/_users/org.couchdb.user:${database}" > /dev/null

          ${pkgs.curl}/bin/curl -s -X PUT -u "$admin_auth" \
            -H "Content-Type: application/json" \
            -d '{"admins":{"names":["${database}"],"roles":[]},"members":{"names":["${database}"],"roles":[]}}' \
            "$base/${database}/_security"
        '';

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
      }
    ) databases
  );
}
