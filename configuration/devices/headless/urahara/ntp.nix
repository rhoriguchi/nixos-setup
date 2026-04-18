{ config, lib, ... }:
let
  subnetsWithNtp = lib.filter (
    subnet: lib.any (opt: opt.name == "ntp-servers") (subnet.option-data or [ ])
  ) config.services.kea.dhcp4.settings.subnet4;

  ntpInterfaces = map (subnet: subnet.interface) subnetsWithNtp;
in
{
  networking.firewall.interfaces = lib.listToAttrs (
    map (
      interfaceName:
      lib.nameValuePair interfaceName {
        allowedUDPPorts = [
          123 # NTP
        ];
      }
    ) ntpInterfaces
  );

  services.chrony = {
    enable = true;

    extraConfig = ''
      allow 10.0.0.0/8
      allow 172.16.0.0/12
      allow 192.168.0.0/16
    '';
  };
}
