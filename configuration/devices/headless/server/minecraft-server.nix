{ config, pkgs, lib, secrets, ... }:
let blueMapPort = 8100;
in {
  environment.shellAliases =
    lib.mapAttrs' (key: _: lib.nameValuePair "attach-minecraft-server-${key}" "${pkgs.tmux}/bin/tmux -S /run/minecraft/${key}.sock attach")
    config.services.minecraft-servers.servers;

  services = {
    infomaniak = {
      enable = true;

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
      hostnames = [ "minecraft.00a.ch" ];
    };

    nginx = {
      enable = true;

      virtualHosts."minecraft.00a.ch" = {
        enableACME = true;
        forceSSL = true;

        locations."/".proxyPass = "http://127.0.0.1:${toString blueMapPort}";
      };
    };

    minecraft-servers = {
      enable = true;
      eula = true;

      openFirewall = true;

      servers.world = {
        enable = true;

        package = pkgs.paper-server;
        jvmOpts = let memory = 1024 * 4; in "-Xmx${toString memory}M -Xms${toString memory}M";

        # https://minecraft.fandom.com/wiki/Server.properties
        serverProperties = rec {
          #https://mctools.org/motd-creator?text=%26d%26lPingu+Land
          motd = "\\u00A7d\\u00A7lPingu Land";
          white-list = true;

          difficulty = "normal";
          view-distance = 32;
          enable-command-block = true;
        };

        symlinks = {
          "plugins/BlueMap.jar" = let
            owner = "BlueMap-Minecraft";
            repo = "BlueMap";
            rev = "5.5";
            sha256 = "sha256-nZxBbF1KkGHveZCKPJ0hHyJGXHnNSCKTvX5JRr0+s88=";
          in pkgs.fetchurl {
            url = "https://github.com/${owner}/${repo}/releases/download/v${rev}/bluemap-${rev}-paper.jar";
            inherit sha256;
          };
          "plugins/BlueMap/core.conf" = pkgs.writeText "core.conf" ''
            accept-download: true
            metrics: false
          '';
          "plugins/BlueMap/packs/BlueMapSpawnMarker.jar" = let
            owner = "TechnicJelle";
            repo = "BlueMapSpawnMarker";
            rev = "1.1";
            sha256 = "sha256-6wZ0Ns6RulKjIuJ3zpxg4MnmgHHD0AdByYE+s+sIk8w=";
          in pkgs.fetchurl {
            url = "https://github.com/${owner}/${repo}/releases/download/v${rev}/BlueMapSpawnMarker-${rev}.jar";
            inherit sha256;
          };
          "plugins/BlueMap/webserver.conf" = pkgs.writeText "webserver.conf" ''
            ip: "127.0.0.1"
            port: ${toString blueMapPort}
          '';

          "plugins/PrometheusExporter.jar" = let
            owner = "sladkoff";
            repo = "minecraft-prometheus-exporter";
            rev = "3.1.0";
            sha256 = "sha256-An5zkJJop2CEkCtjgzOroelQVY0bxLDvH/uhex24YyI=";
          in pkgs.fetchurl {
            url = "https://github.com/${owner}/${repo}/releases/download/v${rev}/minecraft-prometheus-exporter-${rev}.jar";
            inherit sha256;
          };
        };

        # https://mcuuid.net
        whitelist = {
          BlueSwordLily = "fae3385f-2716-496a-9741-011c7774cf31"; # Matteo +1
          DrGolden = "f3cc5386-5866-4e39-b73e-ffd63abc5bec"; # Jeremy
          GhostMoon = "0da68ac3-aa82-442b-b12e-42d864c629b7"; # Rabia
          Ice3ider = "375fd1d3-f816-43ab-813d-19e907f4769f"; # Matteo
          Jeum = "f9fbd9b1-bb8b-4aa6-8e40-b6cc67905487"; # Jessy
          nielsx3 = "a2d4ac95-9a30-4f88-946c-05b60cfaf28b"; # Niels
          Papierschorle = "fd048705-cb86-4e31-a251-1a99d5d2483f"; # Ramon
          Probefahrer = "bbc822d0-2ad2-44f1-94c3-e185cf4d74b4"; # Cyrill
          sanlitun = "9c645c2c-1a1b-4207-ab9e-1ea0ca75a127"; # Isler
          Sebolar = "3a0c19ba-765a-4f86-a981-acf48c5b17da"; # Mike
          Sirkii = "5e14c507-16cd-4a0d-84bd-ec82c1792e03"; # Keanu
          ThatOneSlave = "ee4c4772-23d4-4cc9-9f70-092aa1ddc7c2"; # Janik
          thripphy = "3607cdd3-c5fc-475a-94ae-10e0732c1b69"; # Cipi
          XD3NNY_ = "844269e7-d1f0-4a22-8067-f1d89fe8dd25"; # Denny
          XXLPitu = "91469f95-dded-484b-acde-1da375f88aed"; # Ryan
        };
      };
    };
  };
}
