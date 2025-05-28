{ config, lib, pkgs, ... }:
let
  cfg = config.services.lancache;

  src = pkgs.fetchFromGitHub {
    owner = "uklans";
    repo = "cache-domains";
    rev = "67535f7b9f32ca0bdbb6210c29f16493c9112a7b";
    hash = "sha256-GsUQYB+MpLPBKTZ+cKjjUIiag+KmZgzTe5nC+UIinKE=";
  };

  metadata = (builtins.fromJSON (builtins.readFile "${src}/cache_domains.json")).cache_domains;
  filteredMetadata = lib.filter (cacheDomain: lib.elem cacheDomain.name cfg.cachedServices) metadata;
  domainFiles = lib.flatten (map (cacheDomain: cacheDomain.domain_files) filteredMetadata);
  rawCacheDomains = lib.flatten (map (domainFile: (lib.splitString "\n" (builtins.readFile "${src}/${domainFile}"))) domainFiles);
  cacheDomains = lib.filter (domain: domain != "") rawCacheDomains;
in {
  options.services.lancache = {
    enable = lib.mkEnableOption "LanCache";
    httpPort = lib.mkOption {
      type = lib.types.port;
      default = 15411;
    };
    httpsPort = lib.mkOption {
      type = lib.types.port;
      default = 15412;
    };
    statusPort = lib.mkOption {
      type = lib.types.port;
      default = 15413;
    };
    cacheDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/cache/lancache";
    };
    cachedServices = let services = map (cacheDomain: cacheDomain.name) metadata;
    in lib.mkOption {
      type = lib.types.listOf (lib.types.enum services);
      default = services;
    };
    upstreamDns = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "1.1.1.1" "1.0.0.1" ];
    };
    cacheDomains = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = cacheDomains
        # needed for steam download to work
        ++ lib.optional (lib.elem "steam" cfg.cachedServices) "*.steamcontent.com";
      readOnly = true;
    };
  };

  config = lib.mkIf cfg.enable {
    # https://hub.docker.com/r/lancachenet/monolithic
    virtualisation.oci-containers.containers.lancache = {
      image = "lancachenet/monolithic:latest";

      environment = rec {
        UPSTREAM_DNS = lib.concatStringsSep " " cfg.upstreamDns;
        USE_GENERIC_CACHE = "true";

        MIN_FREE_DISK = "10g";
        CACHE_DISK_SIZE = "2000g";
        CACHE_INDEX_SIZE = "${toString (lib.toInt (lib.head (lib.splitString "g" CACHE_DISK_SIZE)) / 1000 * 250)}m";
        CACHE_MAX_AGE = "${toString (365 * 10)}d";

        TZ = config.time.timeZone;
      };

      ports =
        [ "127.0.0.1:${toString cfg.httpPort}:80" "127.0.0.1:${toString cfg.httpsPort}:443" "127.0.0.1:${toString cfg.statusPort}:8080" ];

      volumes = [ "${cfg.cacheDir}:/data/cache" "/var/log/lancach:/data/logs" ];
    };

    system.activationScripts.lancache = ''
      mkdir -p ${cfg.cacheDir}
      mkdir -p /var/log/lancach
    '';
  };
}
