{
  config,
  interfaces,
  lib,
  ...
}:
let
  internalInterface = interfaces.internal;

  internalInterfaces = lib.filter (interface: lib.hasPrefix internalInterface interface) (
    lib.attrNames config.networking.interfaces
  );

  internalSubnets = lib.filter (
    subnet: lib.hasPrefix internalInterface subnet.interface
  ) config.services.kea.dhcp4.settings.subnet4;
  subnetsWithDns = lib.filter (
    subnet: lib.any (opt: opt.name == "domain-name-servers") (subnet.option-data or [ ])
  ) internalSubnets;

  dnsByInterface = lib.listToAttrs (
    map (
      subnet:
      lib.nameValuePair subnet.interface
        (lib.findFirst (opt: opt.name == "domain-name-servers") null (subnet.option-data or [ ])).data
    ) subnetsWithDns
  );
in
{
  networking = {
    nftables = {
      enable = true;

      tables.dns-firewall = {
        family = "inet";

        content = ''
          chain forward {
            # Run before `firewall` forward chain
            type filter hook forward priority filter - 10; policy accept;

            iifname { ${lib.concatStringsSep ", " internalInterfaces} } oifname { ${config.networking.nat.externalInterface} } \
              meta l4proto { tcp, udp } th dport { 853 } \
              reject

            iifname { ${lib.concatStringsSep ", " internalInterfaces} } oifname { ${config.networking.nat.externalInterface} } \
              meta nfproto ipv6 \
              meta l4proto { tcp, udp } th dport { 53 } \
              reject
          }

          chain prerouting {
            # Run before `nixos-nat` prerouting chain
            type nat hook prerouting priority dstnat - 10;

            meta l4proto { tcp, udp } th dport { 53 } jump dns-dnat
          }

          chain dns-dnat {
            ${lib.concatStringsSep "\n" (
              lib.mapAttrsToList (interface: dnsIp: ''
                iifname { ${interface} } \
                  ip daddr != ${dnsIp} \
                  meta l4proto { tcp, udp } \
                  dnat ip to ${dnsIp}:53
              '') dnsByInterface
            )}

            accept
          }
        '';
      };
    };
  };
}
