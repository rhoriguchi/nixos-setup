{
  config,
  lib,
  secrets,
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

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
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

  systemd.services = lib.listToAttrs (
    map
      (
        name:
        lib.nameValuePair name {
          serviceConfig.LoadCredential = [
            "id_ed25519:${config.sops.secrets."services/rustdesk/privateKey".path}"
            "id_ed25519.pub:${config.sops.secrets."services/rustdesk/publicKey".path}"
          ];

          preStart = ''
            install -m 400 "$CREDENTIALS_DIRECTORY/id_ed25519" id_ed25519
            install -m 400 "$CREDENTIALS_DIRECTORY/id_ed25519.pub" id_ed25519.pub
          '';
        }
      )
      [
        "rustdesk-signal"
        "rustdesk-relay"
      ]
  );

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
