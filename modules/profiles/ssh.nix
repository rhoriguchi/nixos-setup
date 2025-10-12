{ config, lib, ... }:
{
  networking.nftables.tables.ssh = {
    family = "inet";

    content = ''
      set rfc1918 {
        type ipv4_addr;
        flags interval;
        elements = { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 }
      }

      chain input {
        # Run after nixos-fw input chain, because of `services.openssh.openFirewall = true`
        type filter hook input priority filter + 10;

        tcp dport { ${
          lib.concatStringsSep ", " (map (port: toString port) config.services.openssh.ports)
        } } jump ssh-filter
      }

      chain ssh-filter {
        ${lib.optionalString config.services.tailscale.enable "iifname { ${config.services.tailscale.interfaceName} } accept"}
        iifname { lo } accept

        ip saddr @rfc1918 accept

        drop
      }
    '';
  };

  services.openssh = {
    enable = true;

    openFirewall = true;

    authorizedKeysInHomedir = false;
    authorizedKeysFiles = [ "/etc/ssh/authorized_keys.d/root" ];

    settings = {
      KbdInteractiveAuthentication = false;
      PasswordAuthentication = false;
    };
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL8rD8sFsnIBybHVwViGC33aT/pgWBtRNawtmGl8g2yU ryan.horiguchi@gmail.com"
  ];
}
