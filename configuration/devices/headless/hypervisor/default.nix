{ pkgs, ... }: {
  imports = [ ../common.nix ./hardware-configuration.nix ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    initrd.mdadmConf = ''
      ARRAY /dev/md0 metadata=1.2 name=XXLPitu-Hypervisor:0 UUID=58e72fa6:8357b906:89668f63:0f7e4785
    '';

    kernelModules = [ "kvm-amd" "kvm-intel" ];
  };

  networking = {
    hostName = "XXLPitu-Hypervisor";

    interfaces = {
      enp5s0.useDHCP = true;
      enp6s0.useDHCP = true;
      wlp4s0.useDHCP = true;
    };
  };

  virtualisation.libvirtd.enable = true;

  services.duckdns = {
    enable = true;

    token = (import ../../../secrets.nix).services.duckdns.token;
    subdomains = [ "xxlpitu-home" ];
  };
}
