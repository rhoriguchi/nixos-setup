{ pkgs, secrets, ... }:
let
  privateKey = pkgs.writeText "id_ed25519" secrets.rustdesk.privateKey;
  publicKey = pkgs.writeText "id_ed25519.pub" secrets.rustdesk.publicKey;
in
{
  services = {
    infomaniak = {
      enable = true;

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
      hostnames = [ "rustdesk.00a.ch" ];
    };

    rustdesk-server = {
      enable = true;

      signal = {
        relayHosts = [ "rustdesk.00a.ch" ];
        extraArgs = [
          "--key"
          secrets.rustdesk.publicKey
          "--mask"
          "192.168.0.0/16"
        ];
      };

      relay.extraArgs = [
        "--key"
        secrets.rustdesk.publicKey
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "L+ /var/lib/rustdesk/id_ed25519 - - - - ${privateKey}"
    "L+ /var/lib/rustdesk/id_ed25519.pub - - - - ${publicKey}"
  ];

  networking.firewall = {
    allowedTCPPorts = [
      21115
      21116
      21117
      21118
      21119
    ];

    allowedUDPPorts = [ 21116 ];
  };
}
