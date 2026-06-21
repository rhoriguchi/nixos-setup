{
  config,
  interfaces,
  lib,
  ...
}:
let
  internalInterface = interfaces.internal;

  internalSubnetsWithDns = lib.pipe config.services.kea.dhcp4.settings.subnet4 [
    (lib.filter (subnet: lib.hasPrefix internalInterface subnet.interface))
    (lib.filter (subnet: lib.any (opt: opt.name == "domain-name-servers") (subnet.option-data or [ ])))
  ];

  internalSubnetsByInterface = lib.pipe internalSubnetsWithDns [
    (map (
      subnet:
      let
        dnsOpt = lib.findFirst (opt: opt.name == "domain-name-servers") null (subnet.option-data or [ ]);
      in
      lib.nameValuePair subnet.interface dnsOpt.data
    ))

    lib.listToAttrs
  ];

  internalDnsInterfaces = map (subnet: subnet.interface) internalSubnetsWithDns;
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

            iifname { ${lib.concatStringsSep ", " internalDnsInterfaces} } oifname { ${config.networking.nat.externalInterface} } \
              meta l4proto { tcp, udp } th dport { 853 } \
              reject

            iifname { ${lib.concatStringsSep ", " internalDnsInterfaces} } oifname { ${config.networking.nat.externalInterface} } \
              meta nfproto ipv6 \
              meta l4proto { tcp, udp } th dport { 53 } \
              reject
          }

          chain prerouting {
            # Run before `nixos-nat` prerouting chain
            type nat hook prerouting priority dstnat - 10;

            meta l4proto { tcp, udp } th dport { 53 } jump dns-dnat-filter
          }

          chain dns-dnat-filter {
            ${lib.pipe internalSubnetsByInterface [
              (lib.mapAttrsToList (
                interface: dnsIp: ''
                  iifname { ${interface} } \
                    ip daddr != ${dnsIp} \
                    meta l4proto { tcp, udp } \
                    dnat ip to ${dnsIp}:53
                ''
              ))

              (lib.concatStringsSep "\n")
            ]}

            accept
          }
        '';
      };
    };
  };
}
