{ config, pkgs, lib, ... }:
let
  routerIp = "192.168.1.1";

  cachedServices = [ "blizzard" "epicgames" "riot" "steam" ];
  lancachePort = 15411;
  nginxStatusPort = 15412;

  src = pkgs.fetchFromGitHub {
    owner = "uklans";
    repo = "cache-domains";
    rev = "67594ce10c85250bf5e3cc3c6f4a0abb90abd25c";
    hash = "sha256-MRyIz1l23B/ibVc1sPi6BwtB0imi47z1gqQxm5PM60Q=";
  };

  metadata = (builtins.fromJSON (builtins.readFile "${src}/cache_domains.json")).cache_domains;
  filteredMetadata = lib.filter (cacheDomain: builtins.elem cacheDomain.name cachedServices) metadata;
  domainFiles = lib.flatten (map (cacheDomain: cacheDomain.domain_files) filteredMetadata);
  rawCacheDomains = lib.flatten (map (domainFile: (lib.splitString "\n" (builtins.readFile "${src}/${domainFile}"))) domainFiles);
  cachedDomains = lib.filter (domain: domain != "") rawCacheDomains;
in {
  # https://hub.docker.com/r/lancachenet/monolithic
  virtualisation.oci-containers.containers.lancache = {
    image = "lancachenet/monolithic:latest";

    environment = rec {
      UPSTREAM_DNS = lib.concatStringsSep " "
        (map (dns: lib.replaceStrings [ "tls://" ] [ "" ] dns) config.services.adguardhome.settings.dns.bootstrap_dns);
      USE_GENERIC_CACHE = "true";

      MIN_FREE_DISK = "10g";
      CACHE_DISK_SIZE = "2000g";
      CACHE_INDEX_SIZE = "${toString (lib.toInt (builtins.head (lib.splitString "g" CACHE_DISK_SIZE)) / 1000 * 250)}m";
      CACHE_MAX_AGE = "${toString (365 * 10)}d";

      TZ = config.time.timeZone;
    };

    ports = [ "127.0.0.1:${toString lancachePort}:80" "127.0.0.1:${toString nginxStatusPort}:8080" ];

    volumes = [ "/var/cache/lancache:/data/cache" "/var/log/lancach:/data/logs" ];
  };

  system.activationScripts.lancache = ''
    ${pkgs.coreutils}/bin/mkdir -p /var/cache/lancache
    ${pkgs.coreutils}/bin/mkdir -p /var/log/lancach
  '';

  services = {
    nginx.virtualHosts = {
      "localhost".locations."/lancache_status" = {
        proxyPass = "http://127.0.0.1:${toString nginxStatusPort}/nginx_status";

        extraConfig = ''
          access_log off;
          allow 127.0.0.1;
          ${lib.optionalString config.networking.enableIPv6 "allow ::1;"}
          deny all;
        '';
      };
    } // lib.listToAttrs (map (cachedDomain:
      lib.nameValuePair cachedDomain {
        listen = map (addr: {
          inherit addr;
          port = config.services.nginx.defaultHTTPListenPort;
        }) config.services.nginx.defaultListenAddresses;

        locations."/".proxyPass = "http://127.0.0.1:${toString lancachePort}";
      }) cachedDomains);

    adguardhome.settings.filtering.rewrites = map (cachedDomain: {
      domain = lib.replaceStrings [ "*." ] [ "" ] cachedDomain;
      # TODO uncomment when https://github.com/AdguardTeam/AdGuardHome/issues/7327 fixed
      # answer = "${config.networking.hostName}.local";
      answer = routerIp;
    }) cachedDomains;
  };
}
