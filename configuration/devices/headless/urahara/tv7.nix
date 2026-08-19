{
  config,
  interfaces,
  lib,
  pkgs,
  ...
}:
let
  externalInterface = interfaces.external;
  internalInterface = interfaces.internal;

  # igmpproxy only recognises interfaces that carry an IPv4 address (it
  # enumerates them via getifaddrs()). The upstream shadow gets its address
  # from Init7's DHCP (see the tv7-dhcpcd service below). The downstream
  # addresses are static, one per internal network that should receive TV7
  # multicast; the DHCP pools in dhcp/default.nix reserve .254 for this
  # purpose.
  downstreamInterfaces = {
    "${internalInterface}.2" = "192.168.2.254/24";
    "${internalInterface}.3" = "192.168.3.254/24";
    "${internalInterface}.10" = "192.168.10.254/24";
  };

  # https://www.init7.net/en/tv/channels
  multicastSource = "77.109.129.0/24";
  multicastGroup = "233.50.230.0/24";

  netns = "tv7";

  shadowInterfaceOf = interface: "mc-${interface}";
  upstreamShadow = shadowInterfaceOf externalInterface;

  # The upstream shadow ends up leasing the same public address as the real
  # externalInterface (Init7 hands out one address per circuit, not per
  # MAC). macvlan children can't see their own parent's traffic, so that's
  # not a routing conflict, but dhcpcd's normal ARP probe/announce would
  # still contest that address with the real interface on the wire, so ARP
  # is disabled entirely for this client.
  dhcpcdConfigFile = pkgs.writeText "tv7-dhcpcd.conf" "noarp";

  configFile = pkgs.writeText "igmpproxy.conf" ''
    quickleave

    phyint ${upstreamShadow} upstream ratelimit 0 threshold 1
        altnet ${multicastSource}
        whitelist ${multicastGroup}

    ${lib.concatMapStringsSep "\n" (
      interface: "phyint ${shadowInterfaceOf interface} downstream ratelimit 0 threshold 1"
    ) (lib.attrNames downstreamInterfaces)}
  '';

  ip = "${pkgs.iproute2}/bin/ip";

  # Moves a macvlan shadow of `parent` into the tv7 netns as `shadow`,
  # optionally assigning it `address`, and brings it up. Deletes any
  # leftover shadow from a previous (e.g. crashed) run first.
  mkShadowLink =
    {
      parent,
      shadow,
      address ? null,
    }:
    ''
      ${ip} link delete ${shadow} 2> /dev/null || true
      ${ip} link add ${shadow} link ${parent} type macvlan mode bridge
      ${ip} link set ${shadow} netns ${netns}
    ''
    + lib.optionalString (address != null) ''
      ${ip} -n ${netns} addr add ${address} dev ${shadow}
    ''
    + ''
      ${ip} -n ${netns} link set ${shadow} up
    '';
in
{
  systemd.services = {
    # igmpproxy needs exclusive ownership of the kernel's multicast routing
    # table, but FRR's pimd already holds it in the root namespace for the
    # local SSDP/UPnP relay between VLANs. Give igmpproxy its own network
    # namespace with macvlan shadows of the real interfaces, so it gets an
    # independent multicast routing table without disturbing pimd.
    tv7-netns = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      script = ''
        ${ip} netns delete ${netns} 2> /dev/null || true
        ${ip} netns add ${netns}
        ${ip} -n ${netns} link set lo up

        ${mkShadowLink {
          parent = externalInterface;
          shadow = upstreamShadow;
        }}
        ${lib.concatStringsSep "\n" (
          lib.mapAttrsToList (
            interface: address:
            mkShadowLink {
              parent = interface;
              shadow = shadowInterfaceOf interface;
              inherit address;
            }
          ) downstreamInterfaces
        )}
      '';

      preStop = "${ip} netns delete ${netns}";

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
    };

    # Claims an address for the upstream shadow interface from Init7's DHCP,
    # since igmpproxy ignores addressless interfaces.
    tv7-dhcpcd = {
      wantedBy = [ "multi-user.target" ];
      after = [ config.systemd.services.tv7-netns.name ];
      bindsTo = [ config.systemd.services.tv7-netns.name ];

      # --nobackground keeps dhcpcd in the foreground instead of its default
      # fork-once-leased behaviour: that PID file would land inside the
      # TemporaryFileSystem above, invisible to systemd's own PID1 (which
      # reads it from the host mount namespace), so Type=simple tracking the
      # foreground process directly is used instead.
      script = "${pkgs.dhcpcd}/bin/dhcpcd ${
        lib.concatStringsSep " " [
          "--config ${dhcpcdConfigFile}"
          "--ipv4only"
          "--nobackground"
          "${upstreamShadow}"
        ]
      }";

      serviceConfig = {
        NetworkNamespacePath = "/var/run/netns/${netns}";

        # /run/dhcpcd is shared with the root namespace's own dhcpcd, whose
        # control socket lives there: without hiding it, this invocation would
        # just hand our interface to that (root-namespace) master instead of
        # running as its own independent daemon.
        TemporaryFileSystem = "/run/dhcpcd:rw";

        Restart = "on-failure";
        RestartSec = 5;
      };
    };

    igmpproxy = {
      wantedBy = [ "multi-user.target" ];
      after = [
        config.systemd.services.tv7-netns.name
        config.systemd.services.tv7-dhcpcd.name
      ];
      bindsTo = [ config.systemd.services.tv7-netns.name ];

      # tv7-dhcpcd's own job finishes as soon as it forks, before it
      # actually has a lease, so wait for the upstream shadow to carry an
      # address (igmpproxy ignores addressless interfaces) before starting.
      preStart = ''
        for _ in $(seq 1 30); do
          ${ip} -4 addr show ${upstreamShadow} | grep -q "inet " && exit 0
          sleep 1
        done

        echo "${upstreamShadow} still has no IPv4 address after 30s" >&2

        exit 1
      '';

      script = "${pkgs.igmpproxy}/bin/igmpproxy -n ${configFile}";

      serviceConfig = {
        NetworkNamespacePath = "/var/run/netns/${netns}";

        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}
