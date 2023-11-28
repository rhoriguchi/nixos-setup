{ pkgs, lib, config, ... }:
let
  markdownFile = pkgs.writeText "index.md" ''
    ### [home.00a.ch](https://home.00a.ch)

    ${let
      names = lib.attrNames config.services.nginx.virtualHosts;
      filteredNames = lib.filter (name: !(lib.hasSuffix ".local" name)) names;

      line = map (name: "- [${name}](https://${name})") filteredNames;
    in lib.concatStringsSep "\n" (lib.sort (a: b: a < b) line)}
  '';

  indexFile = pkgs.runCommand "index.html" { } "${pkgs.nodePackages.showdown}/bin/showdown makehtml -i ${markdownFile} -o $out";
in {
  systemd.tmpfiles.rules = [
    "d /run/home-page 0700 ${config.services.nginx.user} ${config.services.nginx.group}"
    "L+ /run/home-page/index.html - - - - ${indexFile}"
  ];

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
