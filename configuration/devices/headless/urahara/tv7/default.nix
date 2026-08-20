{
  interfaces,
  lib,
  ...
}:
let
  externalInterface = interfaces.external;
  internalInterface = interfaces.internal;

  downstreamInterfaces = [
    "${internalInterface}.2"
    "${internalInterface}.3"
    "${internalInterface}.10"
  ];

  # FRR's PIM-SM has no way to learn Init7's (non-PIM-speaking) multicast
  # source dynamically, so a real (S,G) forwarding entry never gets built on
  # its own even once a downstream receiver joins and `ip igmp proxy` (below)
  # has made Init7 start sending the channel. A static `ip mroute` per
  # channel/downstream-VLAN pair is the only way to get the kernel to
  # actually forward that traffic once it arrives.
  #
  # https://www.init7.net/en/tv/channels
  channelGroups = lib.pipe (builtins.readFile ./TV7_Multicast.xspf) [
    (builtins.split "(233\\.50\\.230\\.[0-9]+)")
    (builtins.filter builtins.isList)
    (map builtins.head)
    lib.unique
  ];

  staticMroutes = lib.pipe channelGroups [
    (map (group: map (downstream: "  ip mroute ${downstream} ${group}") downstreamInterfaces))
    lib.flatten
    (lib.concatStringsSep "\n")
  ];
in
{
  # IGMPv3 membership reports are sent to the link-local 224.0.0.22, not to
  # the reported group, so they hit the router's own default-deny INPUT
  # policy rather than the forward-hook multicast handling that group-
  # addressed (v1/v2) traffic goes through. Without this, pimd never sees
  # v3 reports at all, silently breaking IGMP-based multicast join tracking.
  networking.firewall.extraInputRules = ''
    iifname { ${
      lib.concatStringsSep ", " ([ externalInterface ] ++ downstreamInterfaces)
    } } ip protocol igmp accept
  '';

  services.frr = {
    pimd.enable = true;

    config = ''
      ip prefix-list TV7_GROUPS seq 5 permit 233.50.230.0/24 le 32

      route-map TV7_PROXY_FILTER permit 10
        match ip multicast-group prefix-list TV7_GROUPS

      interface ${externalInterface}
        ip pim
        ip igmp
        ip igmp version 2
        ip igmp proxy
        ip igmp proxy route-map TV7_PROXY_FILTER

      ${staticMroutes}
    '';
  };
}
