{ config, lib, ... }:
{
  networking.firewall.interfaces = lib.pipe config.services.kea.dhcp4.settings.subnet4 [
    (lib.filter (subnet: lib.any (opt: opt.name == "ntp-servers") (subnet.option-data or [ ])))

    (map (
      subnet:
      lib.nameValuePair subnet.interface {
        allowedUDPPorts = [
          123 # NTP
        ];
      }
    ))

    lib.listToAttrs
  ];

  services.chrony = {
    enable = true;

    extraConfig = ''
      allow 10.0.0.0/8
      allow 172.16.0.0/12
      allow 192.168.0.0/16
    '';
  };
}
