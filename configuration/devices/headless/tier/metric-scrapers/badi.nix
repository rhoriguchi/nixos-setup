{
  config,
  lib,
  pkgs,
  ...
}:
let
  metricsDir = "/run/nginx-badi";
in
{
  systemd.tmpfiles.rules = [
    "d ${metricsDir} 0750 ${config.services.nginx.user} ${config.services.nginx.group}"
  ];

  systemd.services.badi-visitor-collector = {
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    startAt = "*:0/5";

    script = ''
      export LC_ALL=C.UTF-8
      (
        echo "# TYPE badi_max_space gauge"
        echo "# TYPE badi_free_space gauge"
        echo "# TYPE badi_temperature gauge"

        echo '{"action":"subscribe"}' |
          ${pkgs.websocat}/bin/websocat -1 wss://badi-public.crowdmonitor.ch:9591/api |
          ${pkgs.jq}/bin/jq -r '.[] |
            "badi_max_space{id=\"\(.uid | ascii_downcase)\", name=\"\(.name)\"} \(.maxspace | tonumber? // -9999)",
            "badi_free_space{id=\"\(.uid | ascii_downcase)\", name=\"\(.name)\"} \(.freespace | tonumber? // -9999)"'

        # Fetch temperature metrics via XML API
        ${pkgs.curl}/bin/curl -s https://www.stadt-zuerich.ch/stzh/bathdatadownload |
          ${pkgs.xmlstarlet}/bin/xmlstarlet sel -t -m "//bath" \
            -v "concat('badi_temperature{id=\"', translate(poiid, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), '\", name=\"', title, '\"} ')" \
            -i "normalize-space(temperatureWater)" -v "temperatureWater" -b \
            -i "not(normalize-space(temperatureWater))" -o "-9999" -b -n
      ) | ${pkgs.gnused}/bin/sed 's/ä/ae/g; s/ö/oe/g; s/ü/ue/g; s/Ä/Ae/g; s/Ö/Oe/g; s/Ü/Ue/g' > ${metricsDir}/metrics.tmp

      mv ${metricsDir}/metrics.tmp ${metricsDir}/metrics
    '';

    serviceConfig = {
      Type = "oneshot";
      User = config.services.nginx.user;
      Group = config.services.nginx.group;
    };
  };

  services.nginx = {
    enable = true;

    virtualHosts."localhost".locations."/badi/" = {
      alias = "${metricsDir}/";

      extraConfig = ''
        access_log off;

        allow 127.0.0.1;
        deny all;
      '';
    };
  };

  environment.etc = lib.mkIf config.services.alloy.enable {
    "alloy/prometheus.badi.alloy".text = ''
      prometheus.scrape "badi" {
        forward_to = [prometheus.relabel.default.receiver]

        scrape_interval = "${toString (5 * 60)}s"
        scrape_timeout = "5s"

        targets = [
          {
            __address__ = "127.0.0.1:${toString config.services.nginx.defaultHTTPListenPort}",
            __metrics_path__ = "/badi/metrics",
          },
        ]
      }
    '';
  };
}
