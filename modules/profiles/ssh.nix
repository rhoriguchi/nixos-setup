{ config, ... }: {
  networking.firewall.interfaces.${config.services.wireguard-network.interfaceName}.allowedTCPPorts = config.services.openssh.ports;

  services.openssh = {
    enable = true;

    openFirewall = false;

    authorizedKeysInHomedir = false;
    authorizedKeysFiles = [ "/etc/ssh/authorized_keys.d/root" ];

    settings = {
      KbdInteractiveAuthentication = false;
      PasswordAuthentication = false;
    };
  };

  users.users.root.openssh.authorizedKeys.keys =
    [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL8rD8sFsnIBybHVwViGC33aT/pgWBtRNawtmGl8g2yU ryan.horiguchi@gmail.com" ];
}
