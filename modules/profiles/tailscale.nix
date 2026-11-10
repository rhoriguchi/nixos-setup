{ config, lib, ... }:
let
  commonFlags = [
    "--accept-dns=true"
    "--accept-routes=false"
    "--ssh=false"
  ];

  unmanagedInterfaces = lib.filter (
    interface: !lib.hasInfix ":" interface
  ) config.networking.networkmanager.unmanaged;

  hasUnmanagedInterfaces = config.networking.networkmanager.enable && unmanagedInterfaces != [ ];
in
{
  sops.secrets."tailscale+services/headscale/preAuthKeys/${config.networking.hostName}" = {
    key = "services/headscale/preAuthKeys/${config.networking.hostName}";

    restartUnits = [ config.systemd.services.tailscaled-autoconnect.name ];
  };

  networking = lib.mkMerge [
    (lib.mkIf hasUnmanagedInterfaces {
      useNetworkd = true;
      useDHCP = false;

      interfaces = lib.genAttrs unmanagedInterfaces (_: {
        useDHCP = true;
      });
    })

    (lib.mkIf config.services.resolved.enable {
      # dhcpcd runs `resolvconf -d <if>.<protocol>` for events without DNS
      # options (RA, IPv4LL). resolved's shim drops the protocol suffix, so
      # that wipes the DNS servers/domains `<if>.dhcp` set. The kernel handles
      # RAs instead.
      dhcpcd = {
        IPv6rs = false;

        extraConfig = "noipv4ll";
      };

      hosts = {
        "127.0.0.1" = [ "${config.networking.hostName}.local" ];
        "::1" = lib.mkIf config.networking.enableIPv6 [ "${config.networking.hostName}.local" ];
      };
    })
  ];

  systemd.network = lib.mkIf hasUnmanagedInterfaces {
    wait-online.enable = false;

    networks = lib.listToAttrs (
      map (
        interface:
        lib.nameValuePair "40-${interface}" {
          networkConfig.IPv6AcceptRA = true;

          dhcpV4Config.UseDomains = true;
        }
      ) unmanagedInterfaces
    );
  };

  services.resolved = {
    enable = lib.mkDefault true;

    settings.Resolve.MulticastDNS = false;
  };

  services.tailscale = {
    enable = true;

    openFirewall = true;

    useRoutingFeatures = "client";
    disableUpstreamLogging = true;

    authKeyFile =
      config.sops.secrets."tailscale+services/headscale/preAuthKeys/${config.networking.hostName}".path;

    extraSetFlags = commonFlags ++ [
      "--update-check=false"
    ];

    extraUpFlags = commonFlags ++ [
      "--login-server=https://headscale.00a.ch"
      "--force-reauth"
    ];
  };
}
