{
  config,
  lib,
  pkgs,
  ...
}:
let
  metricsDir = "/run/nginx-fitnesspark";

  locations = {
    "508" = {
      locationId = "29";
      state = "Zurich";
      name = "Puls5";
      displayName = "Zurich Puls 5";
    };
    "680" = {
      locationId = "57";
      state = "Aargau";
      name = "Trafo_Baden";
      displayName = "Baden Trafo";
    };
    "682" = {
      locationId = "3";
      state = "Basel";
      name = "Basel_Heuwaage";
      displayName = "Basel Heuwaage";
    };
    "684" = {
      locationId = "4";
      state = "Bern";
      name = "Oberhofen Haupteingang";
      displayName = "Oberhofen indoor pool centre";
    };
    "686" = {
      locationId = "59";
      state = "Bern";
      name = "Time-Out";
      displayName = "Ostermundigen Time-Out";
    };
    "690" = {
      locationId = "54";
      state = "Lucerne";
      name = "National_Luzern";
      displayName = "Lucerne National";
    };
    "694" = {
      locationId = "52";
      state = "Zug";
      name = "Eichstaette_Zug";
      displayName = "Zug Eichstätte";
    };
    "696" = {
      locationId = "6";
      state = "Zurich";
      name = "Winterthur";
      displayName = "Winterthur";
    };
    "698" = {
      locationId = "31";
      state = "Zurich";
      name = "Glattpark";
      displayName = "Zurich Glattpark";
    };
    "700" = {
      locationId = "1";
      state = "Zurich";
      name = "Regensdorf";
      displayName = "Regensdorf";
    };
    "702" = {
      locationId = "30";
      state = "Zurich";
      name = "Stadelhofen";
      displayName = "Zurich Stadelhofen";
    };
    "704" = {
      locationId = "34";
      state = "Zurich";
      name = "Sihlcity";
      displayName = "Zurich Sihlcity";
    };
    "706" = {
      locationId = "32";
      state = "Zurich";
      name = "Stockerhof";
      displayName = "Zurich Stockerhof";
    };
    "856" = {
      locationId = "105";
      state = "Bern";
      name = "Bern_City";
      displayName = "Bern City";
    };
    "2934" = {
      locationId = "12";
      state = "Zurich";
      name = "Milandia";
      displayName = "Greifensee Milandia";
    };
    "3014" = {
      locationId = "4";
      state = "Bern";
      name = "Oberhofen Haupteingang";
      displayName = "Oberhofen";
    };
    "6778" = {
      locationId = "56";
      state = "Lucerne";
      name = "Allmend_Luzern";
      displayName = "Lucerne Allmend";
    };
  };
in
{
  systemd.tmpfiles.rules = [
    "d ${metricsDir} 0750 ${config.services.nginx.user} ${config.services.nginx.group}"
  ];

  systemd.services.fitnesspark-visitor-collector = {
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    startAt = "*:0/5";

    script = ''
      echo "# TYPE fitnesspark_visitors gauge" > ${metricsDir}/metrics.tmp

      get_visitors() {
        local park_id="$1"
        local state="$2"
        local location_id="$3"
        local name="$4"
        local display_name="$5"

        value=$(${pkgs.curl}/bin/curl -s "https://www.fitnesspark.ch/wp/wp-admin/admin-ajax.php?action=single_park_update_visitors&park_id=$park_id&location_id=$location_id&location_name=FP_$name")

        if [[ ! "$value" =~ ^[0-9]+$ ]]; then
          value="-1"
        fi

        echo "fitnesspark_visitors{id=\"$park_id\", state=\"$state\", name=\"$display_name\"} $value" >> ${metricsDir}/metrics.tmp
      }

      ${lib.concatStringsSep "\n" (
        lib.mapAttrsToList (
          parkId: location:
          ''get_visitors "${parkId}" "${lib.toLower location.state}" "${location.locationId}" "${
            lib.replaceStrings [ " " ] [ "%20" ] location.name
          }" "${location.displayName}"''
        ) locations
      )}

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

    virtualHosts."localhost".locations."/fitnesspark/" = {
      alias = "${metricsDir}/";

      extraConfig = ''
        access_log off;

        allow 127.0.0.1;
        ${lib.optionalString config.networking.enableIPv6 "allow ::1;"}
        deny all;
      '';
    };
  };

  environment.etc = lib.mkIf config.services.alloy.enable {
    "alloy/prometheus.fitnesspark.alloy".text = ''
      prometheus.scrape "fitnesspark" {
        forward_to = [prometheus.relabel.default.receiver]

        scrape_interval = "${toString (5 * 60)}s"
        scrape_timeout = "5s"

        targets = [
          {
            __address__ = "127.0.0.1:${toString config.services.nginx.defaultHTTPListenPort}",
            __metrics_path__ = "/fitnesspark/metrics",
          },
        ]
      }
    '';
  };
}
