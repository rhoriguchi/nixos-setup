{ pkgs, lib, config, ... }: {
  imports = [ ../common.nix ./rsnapshot.nix ./synology-mounts.nix ./hardware-configuration.nix ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  networking = {
    hostName = "JDH-Server";

    interfaces = {
      enp8s0.useDHCP = true; # Ethernet
      wlp6s0.useDHCP = true; # WiFi
    };
  };

  services = {
    audio-converter = {
      enable = true;

      user = "plex";
      group = "plex";

      path = "/mnt/Media";
      from = "eac3";
      to = "ac3";
    };

    plex = {
      enable = true;

      openFirewall = true;
    };

    tautulli = {
      enable = true;

      openFirewall = true;
    };
  };

  users.users.jdh = {
    extraGroups = [ "wheel" ];
    isNormalUser = true;
    password = (import ../../../secrets.nix).users.users.jdh.password;
    openssh.authorizedKeys.keys = config.users.users.xxlpitu.openssh.authorizedKeys.keys ++ [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC1NfxYsTB9VSOfoPXZjr9KRn31Td2nooDxhms78yPVs06QAn+0WDoj9KNfK4d5Vf7z8cG1mycAaqy98fWjDzX228hyh67xPJmxTf4PB/ot+QcQ0g2H8c26b6KPm+k+U6uS4frDzLL1xRcPbLs2P0gmVC3JdtvQPMN1y6oOKPIFaYelE3AS9mh6yozH8WSmfL6uocUNkJFF9BkhWiUH1dg62IFKTlm3uVdb+XB50aDf2i96MfeMwfHqXZwRajX9ivhVDFpFI3/CBXbVU7LKLQQNNq2TBospH6KDOPWsfW/20voQwG1hoRLKxQDe3SiTOqomQe9Pba1zVVJ3MIIkhZ/AecMzeeDV2g67v4n0Dvn0EUoa5Obdg14Gci0QY/6Bz31z2eIekUbhFeEpUd8TmVgIvJjUaT+7XtKUqJYPJbsslGhzriN9gq5Mf+0xo4ZDCjiTZhcZIismVmWT+td6kxkkhynRUevIrQfmk/XVhH/33xNOc8VLCZIy5b5/PtTP/gFeSkZ2OA0+avQBb2u0dU+Ivr42sOgAFVRws9fcUDaUUFWrpXg7ueVIlNawvRIt3nbeObmWsH7YxcyxhUekYdUVF3U0BKhPnNn5nWiFPt0iH5G9BUeTBAmMEczNEDcgAPF+7esePYZTeXDBGGBZqPYHbTz1xSnBoKC4s3LY8brGPQ== jdh_10@James-CH-D"
    ];
  };
}
