{ config, ... }:
let
  adguardhomePort = 80;

  # TODO test if all unmodified values are needed
  configValues = {
    bind_host = config.services.adguardhome.host;
    bind_port = config.services.adguardhome.port;
    beta_bind_port = 0;
    users = [{
      name = "admin";
      password = (import ../../../../secrets.nix).services.adguardhome.admin.password;
    }];
    auth_attempts = 5;
    block_auth_min = 15;
    http_proxy = "";
    language = "";
    rlimit_nofile = 0;
    debug_pprof = false;
    web_session_ttl = 720;
    dns = {
      bind_hosts = [ config.services.adguardhome.host ];
      port = 53;
      statistics_interval = 1;
      querylog_enabled = true;
      querylog_file_enabled = true;
      querylog_interval = 90;
      querylog_size_memory = 1000;
      anonymize_client_ip = true;
      protection_enabled = true;
      blocking_mode = "default";
      blocking_ipv4 = "";
      blocking_ipv6 = "";
      blocked_response_ttl = 10;
      parental_block_host = "family-block.dns.adguard.com";
      safebrowsing_block_host = "standard-block.dns.adguard.com";
      ratelimit = 20;
      ratelimit_whitelist = [ ];
      refuse_any = true;
      upstream_dns = [ "tls://1.1.1.1" "tls://dns.google" ];
      upstream_dns_file = "";
      bootstrap_dns = [ "9.9.9.10" "149.112.112.10" "2620:fe::10" "2620:fe::fe:10" ];
      all_servers = false;
      fastest_addr = false;
      allowed_clients = [ ];
      disallowed_clients = [ ];
      blocked_hosts = [ "version.bind" "id.server" "hostname.bind" ];
      cache_size = 4194304;
      cache_ttl_min = 0;
      cache_ttl_max = 0;
      bogus_nxdomain = [ ];
      aaaa_disabled = false;
      enable_dnssec = false;
      edns_client_subnet = false;
      max_goroutines = 300;
      ipset = [ ];
      filtering_enabled = true;
      filters_update_interval = 24;
      parental_enabled = false;
      safesearch_enabled = false;
      safebrowsing_enabled = false;
      safebrowsing_cache_size = 1048576;
      safesearch_cache_size = 1048576;
      parental_cache_size = 1048576;
      cache_time = 30;
      rewrites = [{
        domain = "xxlpitu-hs.duckdns.org";
        answer = "192.168.1.150";
      }];
      blocked_services = [ ];
      local_domain_name = "local";
      resolve_clients = true;
      local_ptr_upstreams = [ ];
    };
    tls = {
      enabled = false;
      server_name = "";
      force_https = false;
      port_https = 443;
      port_dns_over_tls = 853;
      port_dns_over_quic = 784;
      port_dnscrypt = 0;
      dnscrypt_config_file = "";
      allow_unencrypted_doh = false;
      strict_sni_check = false;
      certificate_chain = "";
      private_key = "";
      certificate_path = "";
      private_key_path = "";
    };
    filters = [
      {
        enabled = true;
        url = "https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt";
        name = "AdGuard DNS filter";
        id = 1;
      }
      {
        enabled = false;
        url = "https://adaway.org/hosts.txt";
        name = "AdAway Default Blocklist";
        id = 2;
      }
      {
        enabled = false;
        url = "https://www.malwaredomainlist.com/hostslist/hosts.txt";
        name = "MalwareDomainList.com Hosts List";
        id = 4;
      }
    ];
    whitelist_filters = [ ];
    user_rules = [ ];
    dhcp = {
      enabled = false;
      interface_name = "";
      dhcpv4 = {
        gateway_ip = "";
        subnet_mask = "";
        range_start = "";
        range_end = "";
        lease_duration = 86400;
        icmp_timeout_msec = 1000;
        options = [ ];
      };
      dhcpv6 = {
        range_start = "";
        lease_duration = 86400;
        ra_slaac_only = false;
        ra_allow_slaac = false;
      };
    };
    clients = [ ];
    log_compress = false;
    log_localtime = false;
    log_max_backups = 0;
    log_max_size = 100;
    log_max_age = 3;
    log_file = "";
    verbose = false;
    schema_version = 10;
  };
in {
  imports = [ ../common.nix ./hardware-configuration.nix ];

  networking.hostName = "XXLPitu-AdGuard";

  services = {
    nginx = {
      enable = true;

      virtualHosts."adguardhome" = {
        # TODO commented
        # forceSSL = true;
        # enableACME = true;

        # TODO only allow request from local network

        listen = [{
          addr = "0.0.0.0";
          port = adguardhomePort;
        }];

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.adguardhome.port}";
          proxyWebsockets = true;
        };
      };
    };

    adguardhome = {
      enable = true;

      config = configValues;
    };
  };

  # TODO more ports needed? https://i.imgur.com/zFYaiyp.png
  networking.firewall = {
    allowedTCPPorts = [ 53 adguardhomePort ];
    allowedUDPPorts = [ 53 ];
  };
}
