{
  config,
  lib,
  ...
}:
let
  rustdeskUnitNames = [
    config.systemd.services.rustdesk-signal.name
    config.systemd.services.rustdesk-relay.name
  ];
in
{
  sops.secrets = {
    "services/rustdesk/privateKey".restartUnits = rustdeskUnitNames;
    "services/rustdesk/publicKey".restartUnits = rustdeskUnitNames;
  };

  services = {
    infomaniak = {
      enable = true;

      hostnames = [ "rustdesk.00a.ch" ];
    };

    rustdesk-server = {
      enable = true;

      signal = {
        relayHosts = [ "rustdesk.00a.ch" ];
        extraArgs = [
          "--mask"
          "192.168.0.0/16"
        ];
      };
    };
  };

  systemd.services =
    lib.genAttrs
      [
        "rustdesk-signal"
        "rustdesk-relay"
      ]
      (_: {
        serviceConfig.LoadCredential = [
          "id_ed25519:${config.sops.secrets."services/rustdesk/privateKey".path}"
          "id_ed25519.pub:${config.sops.secrets."services/rustdesk/publicKey".path}"
        ];

        preStart = ''
          for key in id_ed25519 id_ed25519.pub; do
            install -m 400 "$CREDENTIALS_DIRECTORY/$key" "$key.$$"
            mv -f "$key.$$" "$key"
          done
        '';
      });

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
