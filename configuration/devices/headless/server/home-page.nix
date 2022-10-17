{ pkgs, lib, config, ... }:
let
  indexFile = pkgs.writeText "index.html" ''
    <!DOCTYPE html>
    <html>
      <body>

      <h1>home.00a.ch</h1>

      <ul>
        ${
          let
            names = lib.attrNames config.services.nginx.virtualHosts;
            filteredNames = lib.filter (name: !(lib.hasSuffix ".local" name)) names;

            line = map (name: ''<li><a href="https://${name}" target="_blank">${name}</a></li>'') filteredNames;
          in lib.concatStringsSep "\n" (lib.sort (a: b: a < b) line)
        }
      </ul>

      </body>
    </html>
  '';
in {
  systemd.tmpfiles.rules = [ "d /run/home-page 0700 nginx nginx" "L+ /run/home-page/index.html - - - - ${indexFile}" ];

  services.nginx = {
    enable = true;

    virtualHosts."home.00a.ch" = {
      enableACME = true;
      forceSSL = true;

      locations."/" = {
        root = "/run/home-page";
        index = "index.html";
        tryFiles = "$uri /index.html";
      };
    };
  };
}
