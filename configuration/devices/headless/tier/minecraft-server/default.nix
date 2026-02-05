{
  config,
  lib,
  pkgs,
  secrets,
  ...
}:
let
  rootBindmountDir = "/mnt/bindmount/nginx";
  bindmountDir = "${rootBindmountDir}/blue-map-web-root";

  proxyPort = 25565;

  serverPort = 25566;
  serverName = "world";
  package = pkgs.paperServers.paper-1_21_11;

  # https://mcuuid.net
  whitelist = {
    _Selenia_ = "566e0135-4676-4a70-bf1c-705649629a7e"; # Jenny
    _wiesel_ = "bf879f6a-b1f1-42b4-8407-60ba33d95263"; # Joël
    DrGolden = "f3cc5386-5866-4e39-b73e-ffd63abc5bec"; # Jeremy
    GhostMoon = "0da68ac3-aa82-442b-b12e-42d864c629b7"; # Rabia
    Ice3ider = "375fd1d3-f816-43ab-813d-19e907f4769f"; # Matteo
    Jenny1342 = "b8e89fe2-0ec3-4250-b50d-ae63fe414ce5"; # Jenny
    Jeum = "f9fbd9b1-bb8b-4aa6-8e40-b6cc67905487"; # Jessy
    nielsx3 = "a2d4ac95-9a30-4f88-946c-05b60cfaf28b"; # Niels
    Papierschorle = "fd048705-cb86-4e31-a251-1a99d5d2483f"; # Ramon
    Probefahrer = "bbc822d0-2ad2-44f1-94c3-e185cf4d74b4"; # Cyrill
    sanlitun = "9c645c2c-1a1b-4207-ab9e-1ea0ca75a127"; # Isler
    Saregun = "420e8909-a9a1-4974-8e90-5f6f24d9189a"; # Janik
    Sebolar = "3a0c19ba-765a-4f86-a981-acf48c5b17da"; # Mike
    Sirkii = "5e14c507-16cd-4a0d-84bd-ec82c1792e03"; # Keanu
    ThatOneSlave = "ee4c4772-23d4-4cc9-9f70-092aa1ddc7c2"; # Janik
    thripphy = "3607cdd3-c5fc-475a-94ae-10e0732c1b69"; # Cipi
    XD3NNY_ = "844269e7-d1f0-4a22-8067-f1d89fe8dd25"; # Denny
    XXLPitu = "91469f95-dded-484b-acde-1da375f88aed"; # Ryan
  };

  blueMapPort = 8100;
  blueMapWebRoot = "${config.services.minecraft-servers.dataDir}/${serverName}/bluemap/web";
in
{
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

  systemd.tmpfiles.rules = [
    "d ${rootBindmountDir} 0550 ${config.services.nginx.user} ${config.services.nginx.group}"
    "d ${bindmountDir} 0550 ${config.services.nginx.user} ${config.services.nginx.group}"
  ];

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
        proxy = {
          enable = true;

          openFirewall = true;

          package = pkgs.velocityServers.velocity;

          # https://docs.papermc.io/velocity/tuning/#tune-your-startup-flags
          jvmOpts =
            let
              memory = 1024 * 0.5;
            in
            lib.concatStringsSep " " [
              "-Xms${toString (builtins.floor memory)}M"
              "-Xmx${toString (builtins.floor memory)}M"

              "-XX:+UseG1GC"
              "-XX:G1HeapRegionSize=4M"
              "-XX:+UnlockExperimentalVMOptions"
              "-XX:+ParallelRefProcEnabled"
              "-XX:+AlwaysPreTouch"
              "-XX:MaxInlineLevel=15"
            ];

          restart = "on-abort";

          serverProperties.server-port = proxyPort;

          # `server-uuid` is random id that `bStats` uses to identify server
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

              player-info-forwarding-mode = "modern";
              forwarding-secret-file = pkgs.writeText "forwarding.secret" secrets.minecraft.forwardingSecret;

              ping-passthrough = "ALL";

              show-max-players = lib.length (lib.attrNames whitelist);
              online-mode = true;

              servers = {
                "${serverName}" = "127.0.0.1:${toString serverPort}";

                try = [ serverName ];
              };

              forced-hosts."minecraft.00a.ch" = [ serverName ];
            };

            "plugins/VelocityWhitelistr.jar" =
              let
                owner = "TISUnion";
                repo = "VelocityWhitelist";
                tag = "0.3.0";
                sha256 = "sha256-FnVjNnuYy1Vqrh750Bf+Pmsf55dVu2ylplK3lHBf4OA=";
              in
              pkgs.fetchurl {
                url = "https://github.com/${owner}/${repo}/releases/download/v${tag}/VelocityWhitelist-${tag}.jar";
                inherit sha256;
              };
            "plugins/velocitywhitelist/config.yml" = pkgs.writers.writeYAML "config.yml" {
              enabled = true;

              identify_mode = "uuid";
            };
            "plugins/velocitywhitelist/whitelist.yml" = pkgs.writers.writeYAML "whitelist.toml" {
              uuids = lib.attrValues whitelist;
            };
          };
        };

        "${serverName}" = {
          enable = true;

          openFirewall = false;

          inherit package;

          # https://docs.papermc.io/paper/aikars-flags/#recommended-jvm-startup-flags
          jvmOpts =
            let
              memory = 1024 * 6;
            in
            lib.concatStringsSep " " [
              "-Xms${toString (builtins.floor memory)}M"
              "-Xmx${toString (builtins.floor memory)}M"

              "-XX:+UseG1GC"
              "-XX:+ParallelRefProcEnabled"
              "-XX:MaxGCPauseMillis=200"
              "-XX:+UnlockExperimentalVMOptions"
              "-XX:+DisableExplicitGC"
              "-XX:+AlwaysPreTouch"
              "-XX:G1NewSizePercent=30"
              "-XX:G1MaxNewSizePercent=40"
              "-XX:G1HeapRegionSize=8M"
              "-XX:G1ReservePercent=20"
              "-XX:G1HeapWastePercent=5"
              "-XX:G1MixedGCCountTarget=4"
              "-XX:InitiatingHeapOccupancyPercent=15"
              "-XX:G1MixedGCLiveThresholdPercent=90"
              "-XX:G1RSetUpdatingPauseTimePercent=5"
              "-XX:SurvivorRatio=32"
              "-XX:+PerfDisableSharedMem"
              "-XX:MaxTenuringThreshold=1"
            ];

          restart = "on-abort";

          # https://docs.papermc.io/paper/reference/server-properties
          serverProperties = {
            server-port = serverPort;
            server-ip = "127.0.0.1";

            # https://mctools.org/motd-creator?text=%26d%26lPingu+Land
            motd = ''\u00A7d\u00A7lPingu Land'';

            online-mode = false; # done by velocity

            difficulty = "normal";
            view-distance = 32;
            enable-command-block = true;

            max-players = lib.length (lib.attrNames whitelist);
          };

          extraStartPost = ''
            ${pkgs.yq-go}/bin/yq -i '.entities.behavior.zombie-villager-infection-chance = 100.0' \
              ${config.services.minecraft-servers.dataDir}/${serverName}/config/paper-world-defaults.yml
          '';

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
            # Make sure that this path does not change after every commit
            "server-icon.png" = pkgs.runCommand "server-icon.png" { } ''
              cp ${./server-icon.png} $out
            '';

            "plugins/BlueMap.jar" =
              let
                owner = "BlueMap-Minecraft";
                repo = "BlueMap";
                tag = "5.15";
                sha256 = "sha256-FgWc3yM8CqDS2n2Lat0eOyCQfxokE0zCB/VX18Gy444=";
              in
              pkgs.fetchurl {
                url = "https://github.com/${owner}/${repo}/releases/download/v${tag}/bluemap-${tag}-paper.jar";
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
            "plugins/BlueMap/packs/BlueMapSpawnMarker.jar" =
              let
                owner = "TechnicJelle";
                repo = "BlueMapSpawnMarker";
                tag = "1.2";
                sha256 = "sha256-jjrJ5nl7ETsGBMyx8OC//8AXcQ0DbU7jpGeHjeGZEsM=";
              in
              pkgs.fetchurl {
                url = "https://github.com/${owner}/${repo}/releases/download/v${tag}/BlueMapSpawnMarker-${tag}.jar";
                inherit sha256;
              };

            "plugins/PrometheusExporter.jar" =
              let
                owner = "sladkoff";
                repo = "minecraft-prometheus-exporter";
                tag = "3.1.2";
                sha256 = "sha256-nfTBS/EQNMuHHSse23Hsc9CiW6mGD4uQ4JYA2D5I2js=";
              in
              pkgs.fetchurl {
                url = "https://github.com/${owner}/${repo}/releases/download/v${tag}/minecraft-prometheus-exporter-${tag}.jar";
                inherit sha256;
              };

            # https://hangar.papermc.io/EngineHub/WorldEdit/versions
            "plugins/WorldEdit.jar" =
              assert lib.versionAtLeast package.version "1.21.3" && lib.versionOlder package.version "1.21.12";
              pkgs.fetchurl {
                url = "https://hangarcdn.papermc.io/plugins/EngineHub/WorldEdit/versions/7.3.18/PAPER/worldedit-bukkit-7.3.18.jar";
                sha256 = "sha256-cSyHxmwFPfRXD3QFvBQXnuWdeIVuJvBKz7KsNwngEkE=";
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
