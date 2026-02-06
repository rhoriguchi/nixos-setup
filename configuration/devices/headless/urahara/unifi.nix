{
  interfaces,
  lib,
  pkgs,
  secrets,
  ...
}:
let
  internalInterface = interfaces.internal;
in
{
  services = {
    unpoller = {
      enable = true;

      unifi.defaults = {
        user = "unifipoller";
        pass = pkgs.writeText "unifipoller-password" secrets.unpoller.users.unifipoller.password;

        url = "https://unifi.local";
        verify_ssl = false;
      };

      influxdb.disable = true;

      prometheus.http_listen = "127.0.0.1:9130";
    };

    netdata.configDir."go.d/snmp.conf" = (pkgs.formats.yaml { }).generate "snmp.conf" {
      jobs = [
        {
          name = "Cloud Key Gen.2";
          hostname = "unifi.local";
          community = "public";
          options.version = 2;
          autodetection_retry = 30;
        }
      ]
      ++
        map
          (name: {
            inherit name;
            hostname = lib.toLower "${lib.replaceStrings [ " " ] [ "" ] name}.local";
            community = "public";
            options.version = 2;
            autodetection_retry = 30;
          })
          [
            "Bedroom - U7 Pro XG"
            "Living room - U6 LR"
            "Living room - US 8 60W"
            "Network closet - USW Pro XG 8 PoE"
            "Office - U7 Pro XG"
            "Office - USW Pro XG 8 PoE"
          ];
    };
  };

  environment.etc."alloy/loki.unifi.alloy".text = ''
    loki.relabel "unifi" {
      forward_to = [loki.relabel.default.receiver]

      rule {
        target_label = "job"
        replacement = "unifi"
      }
    }

    loki.process "unifi" {
      stage.regex {
        expression = "${
          lib.escape [
            "\\"
          ] ''^(?:[\w,\-\.\+]+:\s+|[\w\-]+\s+)?(?P<service_name>[\w\-]+)(?:\[\d+\])?:\s*(?P<message>.*)$''
        }"
      }

      stage.labels {
        values = {
          service_name = "",
        }
      }

      stage.output {
        source = "message"
      }

      forward_to = [loki.relabel.unifi.receiver]
    }

    loki.relabel "raw_unifi_syslog" {
      forward_to = []

      rule {
        source_labels = ["__syslog_message_severity"]
        target_label  = "severity"
      }

      rule {
        source_labels = ["__syslog_message_severity"]
        regex         = "(?i)(emergency|alert|critical)"
        target_label  = "severity"
        replacement   = "crit"
      }

      rule {
        source_labels = ["__syslog_message_severity"]
        regex         = "(?i)(notice|informational)"
        target_label  = "severity"
        replacement   = "info"
      }

      rule {
        source_labels = ["__syslog_message_hostname"]
        target_label  = "hostname"
      }
    }

    loki.source.syslog "unifi" {
      listener {
        address       = "0.0.0.0:514"
        protocol      = "udp"
        syslog_format = "rfc3164"
      }

      relabel_rules = loki.relabel.raw_unifi_syslog.rules
      forward_to = [loki.process.unifi.receiver]
    }
  '';

  networking.firewall.interfaces.${internalInterface}.allowedUDPPorts = [
    514
  ];

  systemd.services.alloy.serviceConfig = {
    CapabilityBoundingSet = [
      "CAP_NET_BIND_SERVICE"
    ];

    AmbientCapabilities = [
      "CAP_NET_BIND_SERVICE"
    ];
  };
}
