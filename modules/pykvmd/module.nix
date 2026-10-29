{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.pykvmd;

  yamlFormat = pkgs.formats.yaml { };

  variantParts = lib.splitString "-" cfg.variant;
  model = builtins.elemAt variantParts 0;
  video = builtins.elemAt variantParts 1;
  board = builtins.elemAt variantParts 2;

  pykvmd = pkgs.pykvmd.override { inherit (cfg) variant; };

  share = "${pykvmd}/share/kvmd";

  platformFile = pkgs.writeText "kvmd-platform" ''
    PIKVM_MODEL=${model}
    PIKVM_VIDEO=${video}
    PIKVM_BOARD=${board}
  '';

  moduleSettings = {
    kvmd = {
      auth = {
        enabled = cfg.auth.enable;
      }
      // lib.optionalAttrs cfg.auth.enable {
        internal.file = cfg.htpasswdFile;
        # no TOTP, the default secret file does not exist
        totp.secret.file = "";
      };

      info = {
        meta = "${share}/configs.default/kvmd/meta.yaml";
        hw.platform = platformFile;
      };

      # the MSD store is a plain directory, nothing to remount
      msd.remount_cmd = [ "${pkgs.coreutils}/bin/true" ];
    };

    # owner of the USB gadget files
    otg.user = "kvmd";
  };

  # nginx proxy target of a unix socket in the runtime directory of kvmd
  socket = name: "http://unix:/run/kvmd/${name}.sock";

  # with kvmd authentication the API handles it itself, nginx only guards the
  # static files
  noAuth = lib.optionalString cfg.auth.enable "auth_request off;";

  # nginx subrequest to kvmd that decides whether a user is logged in
  authLocations = lib.optionalAttrs cfg.auth.enable {
    "= /auth_check" = {
      proxyPass = "${socket "kvmd"}:/auth/check";
      extraConfig = ''
        internal;
        proxy_pass_request_body off;
        proxy_set_header Content-Length "";
        ${noAuth}
      '';
    };

    "/".extraConfig = "error_page 401 403 = @login;";
    "@login".return = "302 /login";
    "/login".extraConfig = noAuth;
    "/share".extraConfig = noAuth;
  };

  # streamed responses, e.g. the MJPEG stream and the log follow mode
  noBuffering = ''
    proxy_buffering off;
    postpone_output 0;
  '';

  # the response of these takes longer than the default 60s
  longRead = "proxy_read_timeout 7d;";

  v4l2 = "${pkgs.v4l-utils}/bin/v4l2-ctl --device=/dev/kvmd-video";

  daemon = {
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [
      "network-online.target"
      "nss-lookup.target"
    ];

    serviceConfig = {
      Restart = "always";
      RestartSec = 3;
      AmbientCapabilities = "CAP_NET_RAW";
      TimeoutStopSec = 10;
      KillMode = "mixed";
    };
  };
in
{
  options.services.pykvmd = {
    enable = lib.mkEnableOption "PiKVM (kvmd) core web KVM stack";

    variant = lib.mkOption {
      type = lib.types.enum [
        "v2-hdmi-rpi3"
        "v2-hdmi-rpi4"
        "v2-hdmi-zero2w"
        "v2-hdmiusb-rpi4"
        "v2-hdmiusb-rpi5"
        "v3-hdmi-rpi4"
        "v4mini-hdmi-rpi4"
      ];
      description = ''
        PiKVM hardware variant in the form `<model>-<video>-<board>`.
        Only variants using the OTG USB gadget for HID are supported.

        The Raspberry Pi device tree overlays (`dwc2` in peripheral mode and,
        for HDMI capture, `tc358743`) are not configured by this module and
        have to be enabled by the hardware configuration of the host.
      '';
    };

    hostName = lib.mkOption {
      type = lib.types.str;
      example = "pikvm.example.com";
      description = ''
        Name of the nginx virtual host the web UI is served on. TLS, ACME and
        the like are configured on `services.nginx.virtualHosts.<hostName>`.
      '';
    };

    auth.enable = lib.mkOption {
      type = lib.types.bool;
      # same as upstream kvmd.auth.enabled
      default = true;
      description = ''
        Whether kvmd requires a login. When disabled, kvmd and the nginx
        virtual host accept every request, so the access has to be restricted
        some other way, e.g. by an authenticating reverse proxy configured on
        `services.nginx.virtualHosts.<hostName>`.
      '';
    };

    htpasswdFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Runtime path of the htpasswd file with the web UI users. It must be
        readable by the `kvmd` user. Required if {option}`services.pykvmd.auth.enable` is set.
      '';
    };

    settings = lib.mkOption {
      type = yamlFormat.type;
      default = { };
      description = ''
        Additional kvmd configuration, written to `/etc/kvmd/override.yaml`
        and merged on top of the settings of this module.
      '';
    };

    webrtcPortRange = {
      from = lib.mkOption {
        type = lib.types.port;
        default = 20000;
        description = ''
          First UDP port Janus may use for the WebRTC video stream.
        '';
      };

      to = lib.mkOption {
        type = lib.types.port;
        default = 20099;
        description = ''
          Last UDP port Janus may use for the WebRTC video stream. Every
          connected viewer needs a port per local address of the interface
          Janus listens on, so the default range is plenty for a few viewers.
        '';
      };
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether to open the WebRTC (Janus RTP) UDP port range in the firewall.
        The HTTP and HTTPS ports of nginx are not opened.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.auth.enable -> cfg.htpasswdFile != null;
        message = "services.pykvmd.htpasswdFile must be set when services.pykvmd.auth.enable is true.";
      }
      {
        assertion = cfg.webrtcPortRange.from <= cfg.webrtcPortRange.to;
        message = "services.pykvmd.webrtcPortRange.from must not be greater than `to`.";
      }
    ];

    environment = {
      systemPackages = [ pykvmd ];

      etc = {
        "kvmd/override.yaml".source = yamlFormat.generate "kvmd-override.yaml" (
          lib.recursiveUpdate moduleSettings cfg.settings
        );

        "kvmd/override.d".source = pkgs.emptyDirectory;

        # configs folder of Janus, the default one of kvmd
        "kvmd/janus".source = pkgs.runCommand "kvmd-janus-config" { } ''
          cp -r ${share}/configs.default/janus $out
          chmod -R u+w $out
          substituteInPlace $out/janus.jcfg \
            --replace-fail \
              'rtp_port_range = "20000-40000"' \
              'rtp_port_range = "${toString cfg.webrtcPortRange.from}-${toString cfg.webrtcPortRange.to}"'
        '';
      };
    };

    users = {
      users = {
        kvmd = {
          isSystemUser = true;
          group = "kvmd";
          description = "PiKVM - The main daemon";
          extraGroups = [
            "gpio"
            "systemd-journal"
            "video"
          ];
        };

        kvmd-janus = {
          isSystemUser = true;
          group = "kvmd-janus";
          description = "PiKVM - Janus WebRTC Gateway";
          extraGroups = [ "kvmd" ];
        };

        # the web server reaches the kvmd and janus sockets through these
        ${config.services.nginx.user}.extraGroups = [
          "kvmd"
          "kvmd-janus"
        ];
      };

      groups = {
        gpio = { };
        kvmd = { };
        kvmd-janus = { };
      };
    };

    boot.kernelModules = [
      "dwc2"
      "libcomposite"
    ]
    ++ lib.optional (video == "hdmi") "tc358743";

    services.udev = {
      packages = [ pykvmd ];

      extraRules = ''
        SUBSYSTEM=="gpio", KERNEL=="gpiochip[0-9]*", GROUP="gpio", MODE="0660"
      '';
    };

    systemd = {
      tmpfiles.rules = [
        "d /run/kvmd 0775 kvmd kvmd -"
        "d /var/lib/kvmd/msd 0755 kvmd kvmd -"
      ];

      services = {
        kvmd-otg = {
          description = "PiKVM - OTG setup";
          wantedBy = [ "multi-user.target" ];
          after = [ config.systemd.services.systemd-modules-load.name ];
          before = [ config.systemd.services.kvmd.name ];

          # re-running kvmd-otg on switch tears down HID/MSD until reboot
          restartIfChanged = false;
          stopIfChanged = false;

          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = "${pykvmd}/bin/kvmd-otg start";
            ExecStop = "${pykvmd}/bin/kvmd-otg stop";
          };
        };

        kvmd-tc358743 = lib.mkIf (video == "hdmi") {
          description = "PiKVM - EDID loader for TC358743";
          wantedBy = [ "multi-user.target" ];
          wants = [ "dev-kvmd\\x2dvideo.device" ];
          after = [
            "dev-kvmd\\x2dvideo.device"
            config.systemd.services.systemd-modules-load.name
          ];
          before = [ config.systemd.services.kvmd.name ];

          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = "${v4l2} --set-edid=file=${share}/configs.default/kvmd/edid/${model}.hex --info-edid";
            ExecStop = "${v4l2} --clear-edid";
          };
        };

        kvmd = lib.mkMerge [
          daemon
          {
            description = "PiKVM - The main daemon";
            after = [ config.systemd.services.kvmd-otg.name ];

            serviceConfig = {
              User = "kvmd";
              Group = "kvmd";
              ExecStart = "${pykvmd}/bin/kvmd --run";
            };
          }
        ];

        kvmd-janus = lib.mkMerge [
          daemon
          {
            description = "PiKVM - Janus WebRTC Gateway";
            after = [ config.systemd.services.kvmd.name ];

            serviceConfig = {
              User = "kvmd-janus";
              Group = "kvmd-janus";
              LimitNOFILE = 65536;
              # UNIX sockets have to be accessible by the group
              UMask = "0117";
              ExecStart = "${pykvmd}/bin/kvmd-janus --run";
            };
          }
        ];
      };
    };

    services.nginx = {
      enable = true;

      virtualHosts.${cfg.hostName} = {
        root = "${share}/web";

        extraConfig = ''
          ${lib.optionalString cfg.auth.enable "auth_request /auth_check;"}

          # the files in the store have a fixed modification time, so browsers
          # would keep an outdated web UI after an update
          add_header Cache-Control "no-store";
        '';

        locations = authLocations // {
          "= /janus/ws" = {
            proxyPass = "${socket "janus-ws"}:/";
            proxyWebsockets = true;
          };

          "/streamer/" = {
            proxyPass = "${socket "ustreamer"}:/";
            extraConfig = noBuffering;
          };

          "/redfish" = {
            proxyPass = socket "kvmd";
            extraConfig = noAuth;
          };

          "= /api/ws" = {
            proxyPass = "${socket "kvmd"}:/ws";
            proxyWebsockets = true;
            extraConfig = noAuth;
          };

          "= /api/hid/print" = {
            proxyPass = "${socket "kvmd"}:/hid/print";
            extraConfig = longRead + noAuth;
          };

          "= /api/msd/read" = {
            proxyPass = "${socket "kvmd"}:/msd/read";
            extraConfig = noBuffering + longRead + noAuth;
          };

          "= /api/msd/write_remote" = {
            proxyPass = "${socket "kvmd"}:/msd/write_remote";
            extraConfig = noBuffering + longRead + noAuth;
          };

          "= /api/msd/write" = {
            proxyPass = "${socket "kvmd"}:/msd/write";
            extraConfig = ''
              client_max_body_size 0;
              proxy_request_buffering off;
              ${noAuth}
            '';
          };

          "= /api/log" = {
            proxyPass = "${socket "kvmd"}:/log";
            extraConfig = noBuffering + longRead + noAuth;
          };

          "/api/" = {
            proxyPass = "${socket "kvmd"}:/";
            extraConfig = noAuth;
          };
        };
      };
    };

    networking.firewall.allowedUDPPortRanges = lib.mkIf cfg.openFirewall [ cfg.webrtcPortRange ];
  };
}
