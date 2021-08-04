{ ... }: {
  imports = [ ../common.nix ./hardware-configuration.nix ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    supportedFilesystems = [ "zfs" ];
  };

  networking = {
    hostName = "XXLPitu-Hypervisor";
    hostId = "c270d3cf";

    interfaces = {
      enp5s0.useDHCP = true;
      enp6s0.useDHCP = true;
      wlp4s0.useDHCP = true;
    };
  };

  services.duckdns = {
    enable = true;

    token = (import ../../../secrets.nix).services.duckdns.token;
    subdomains = [ "xxlpitu-home" ];
  };
}
