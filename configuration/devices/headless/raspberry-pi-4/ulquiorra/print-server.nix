{ config, pkgs, secrets, ... }:
let cupsPort = 631;
in {
  # Required for sane
  boot.kernelModules = [ "sg" "usblp" ];

  hardware = {
    printers.ensurePrinters = [{
      name = "Default";

      # lpinfo -v
      deviceUri = "hp:/usb/ENVY_4500_series?serial=CN4CS2325205X4";

      # lpinfo -m
      model = "HP/hp-envy_4500_series.ppd.gz";

      # lpoptions -p Default -l
      ppdOptions = {
        ColorModel = "KGray";
        Duplex = "None";
        InputSlot = "Auto";
        MediaType = "Plain";
        OptionDuplex = "False";
        OutputMode = "Normal";
        PageSize = "A4";
      };
    }];

    sane = {
      enable = true;

      extraBackends = [ pkgs.hplipWithPlugin ];
    };
  };

  services = {
    # lsusb
    udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="usb", ENV{ID_VENDOR_ID}=="03f0", ENV{ID_MODEL_ID}=="c511", RUN+="${pkgs.systemd}/bin/systemctl restart ensure-printers.service"
    '';

    printing = {
      enable = true;

      stateless = true;

      webInterface = true;
      startWhenNeeded = false;

      # Firewall port needs to be open and listen address needs to be 0.0.0.0 else discovery does not work
      openFirewall = true;
      listenAddresses = [ "0.0.0.0:${toString cupsPort}" ];
      allowFrom = [ "127.0.0.1" "192.168.1.*" ];
      browsing = true;
      defaultShared = true;

      drivers = [ pkgs.hplipWithPlugin ];

      extraConf = ''
        DefaultEncryption Never
      '';
    };

    saned.enable = true;

    scanservjs.enable = true;

    avahi = {
      enable = true;

      openFirewall = true;

      nssmdns4 = true;
      nssmdns6 = true;

      publish = {
        enable = true;
        userServices = true;
      };
    };

    infomaniak = {
      enable = true;

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
      hostnames = [ "printer.00a.ch" "scanner.00a.ch" ];
    };

    nginx = {
      enable = true;

      virtualHosts = {
        "printer.00a.ch" = {
          enableACME = true;
          forceSSL = true;

          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString cupsPort}";

            recommendedProxySettings = false;
            extraConfig = ''
              # cups won't work if this is not 127.0.0.1
              proxy_set_header Host 127.0.0.1;
              proxy_set_header X-Real-IP 127.0.0.1;
              proxy_set_header X-Forwarded-For 127.0.0.1;
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Forwarded-Host $host;
              proxy_set_header X-Forwarded-Server $host;

              allow 192.168.1.0/24;
              deny all;
            '';
          };
        };

        "scanner.00a.ch" = {
          enableACME = true;
          forceSSL = true;

          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString config.services.scanservjs.settings.port}";

            extraConfig = ''
              allow 192.168.1.0/24;
              deny all;
            '';
          };
        };
      };
    };
  };
}
