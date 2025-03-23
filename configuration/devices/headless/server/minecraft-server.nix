{ config, lib, pkgs, secrets, ... }:
let
  rootBindmountDir = "/mnt/bindmount/nginx";
  bindmountDir = "${rootBindmountDir}/blue-map-web-root";

  proxyPort = 25565;

  serverPort = 25566;
  serverName = "world";
  package = pkgs.paper-server;

  # https://mcuuid.net
  whitelist = {
    _wiesel_ = "bf879f6a-b1f1-42b4-8407-60ba33d95263"; # Joël
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

  blueMapPort = 8100;
  blueMapWebRoot = "${config.services.minecraft-servers.dataDir}/${serverName}/bluemap/web";
in {
  system.fsPackages = [ pkgs.bindfs ];
  fileSystems.${bindmountDir} = {
    depends = [ blueMapWebRoot ];
    device = blueMapWebRoot;
    fsType = "fuse.bindfs";
    options = [
      # `ro` causes kernel panic
      "perms=0550"
      "map=${
        lib.concatStringsSep ":" [
          "${config.services.minecraft-servers.user}/${config.services.nginx.user}"
          "@${config.services.minecraft-servers.group}/@${config.services.nginx.group}"
        ]
      }"
    ];
  };

  system.activationScripts.nginx = ''
    mkdir -p ${bindmountDir}
    chown -R ${config.services.nginx.user}:${config.services.nginx.group} ${rootBindmountDir}
  '';

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

        root = bindmountDir;

        locations = {
          "@empty".return = 204;

          "~* ^/maps/[^/]*/live/" = {
            proxyPass = "http://127.0.0.1:${toString blueMapPort}";

            extraConfig = ''
              error_page 404 = @empty;
            '';
          };

          "~* ^/maps/[^/]*/tiles/".extraConfig = ''
            error_page 404 = @empty;
          '';
        };
      };
    };

    minecraft-servers = {
      enable = true;
      eula = true;

      managementSystem.systemd-socket.enable = true;

      servers = {
        proxy = rec {
          enable = true;

          openFirewall = true;

          package = pkgs.velocityServers.velocity;
          jvmOpts = let memory = 1024 * 0.5; in "-Xmx${toString (builtins.floor memory)}M -Xms${toString (builtins.floor memory)}M";

          restart = "on-abort";

          serverProperties.server-port = proxyPort;

          files."plugins/bStats/config.txt" = pkgs.writeText "config.txt" ''
            enabled=false

            server-uuid=5a650f19-3c33-4cbe-865a-1982cdd89e50
            log-errors=false
            log-sent-data=false
            log-response-status-text=false
          '';

          symlinks = {
            # https://docs.papermc.io/velocity/configuration
            "velocity.toml" = pkgs.writers.writeTOML "velocity.toml" {
              config-version = "2.7";

              bind = "0.0.0.0:${toString proxyPort}";

              # https://docs.advntr.dev/minimessage/format.html
              motd = "<light_purple>Pingu Land</light_purple>";

              player-info-forwarding-mode = "modern";
              forwarding-secret-file = pkgs.writeText "forwarding.secret" secrets.minecraft.forwardingSecret;

              show-max-players = builtins.length (builtins.attrNames whitelist);
              online-mode = true;

              servers = {
                "${serverName}" = "127.0.0.1:${toString serverPort}";

                try = [ serverName ];
              };

              forced-hosts."minecraft.00a.ch" = [ serverName ];
            };

            "plugins/VelocityWhitelistr.jar" = let
              owner = "TISUnion";
              repo = "VelocityWhitelist";
              rev = "0.2.0";
              sha256 = "sha256-MBvI8fT1dNg03pPMegOohAz39lzgCNpkHfFzEpy4wd0=";
            in pkgs.fetchurl {
              url = "https://github.com/${owner}/${repo}/releases/download/v${rev}/VelocityWhitelist-${rev}.jar";
              inherit sha256;
            };
            "plugins/velocitywhitelist/config.yml" = pkgs.writers.writeYAML "config.yml" {
              enabled = true;

              identify_mode = "uuid";
            };
            "plugins/velocitywhitelist/whitelist.yml" = pkgs.writers.writeYAML "whitelist.toml" { uuids = lib.attrValues whitelist; };
          };
        };

        "${serverName}" = rec {
          enable = true;

          openFirewall = false;

          inherit package;
          jvmOpts = let memory = 1024 * 4; in "-Xmx${toString (builtins.floor memory)}M -Xms${toString (builtins.floor memory)}M";

          restart = "on-abort";

          # https://docs.papermc.io/paper/reference/server-properties
          serverProperties = {
            server-port = serverPort;
            server-ip = "127.0.0.1";

            online-mode = false; # done by velocity

            difficulty = "normal";
            view-distance = 32;
            enable-command-block = true;

            max-players = builtins.length (builtins.attrNames whitelist);
          };

          files = {
            # https://docs.papermc.io/paper/reference/global-configuration#proxies_velocity
            "config/paper-global.yml" = pkgs.writers.writeYAML "paper-global.yml" {
              proxies.velocity = {
                enabled = true;

                secret = secrets.minecraft.forwardingSecret;
                online-mode = true;
              };

              unsupported-settings.allow-piston-duplication = true;
            };
          };

          symlinks = {
            "plugins/BlueMap.jar" = let
              owner = "BlueMap-Minecraft";
              repo = "BlueMap";
              rev = "5.7";
              sha256 = "sha256-4T9Pf1FA/XlByNTmVIimj+7aCyX/BPy011gdT70mFAk=";
            in pkgs.fetchurl {
              url = "https://github.com/${owner}/${repo}/releases/download/v${rev}/bluemap-${rev}-paper.jar";
              inherit sha256;
            };
            "plugins/BlueMap/core.conf" = pkgs.writeText "core.conf" ''
              accept-download: true
              render-thread-count: 4
              metrics: false
            '';
            "plugins/BlueMap/webserver.conf" = pkgs.writeText "webserver.conf" ''
              ip: "127.0.0.1"
              port: ${toString blueMapPort}
            '';
            "plugins/BlueMap/maps/world_nether_ceiling.conf" = pkgs.writeText "world_nether_ceiling.conf" ''
              world: "world_nether"
              dimension: "minecraft:the_nether"
              name: "world_nether_ceiling (the_nether)"

              sorting: 101

              sky-color: "#290000"
              void-color: "#150000"

              ambient-light: 0.6
              remove-caves-below-y: -10000
              cave-detection-ocean-floor: -5

              min-y: 120
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

            "plugins/PrometheusExporter.jar" = let
              owner = "sladkoff";
              repo = "minecraft-prometheus-exporter";
              rev = "3.1.2";
              sha256 = "sha256-nfTBS/EQNMuHHSse23Hsc9CiW6mGD4uQ4JYA2D5I2js=";
            in pkgs.fetchurl {
              url = "https://github.com/${owner}/${repo}/releases/download/v${rev}/minecraft-prometheus-exporter-${rev}.jar";
              inherit sha256;
            };
          };

          operators.XXLPitu = {
            uuid = whitelist.XXLPitu;
            level = 4;
            bypassesPlayerLimit = true;
          };
        };
      };
    };
  };
}
