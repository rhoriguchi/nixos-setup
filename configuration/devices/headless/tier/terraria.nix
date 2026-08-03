{
  config,
  lib,
  pkgs,
  secrets,
  ...
}:
let
  port = 7777;
  dataDir = "/var/lib/terraria";

  optionFormat = optionName: {
    option = "-${optionName}";
    sep = " ";
    explicitBool = false;
    formatArg = v: ''"${lib.generators.mkValueStringDefault { } v}"'';
  };

  args = lib.cli.toCommandLine optionFormat {
    # 1 (Small) / 2 (Medium) / 3 (Large)
    autocreate = "3";
    worldname = "World";
    world = "${dataDir}/.local/share/Terraria/Worlds/World.wld";

    port = port;
    password = secrets.terraria.password;

    # Triggers `Projectile Spam`
    secure = false;
    noupnp = true;

    maxPlayers = 16;
  };
in
{
  users = {
    users.terraria = {
      group = "terraria";
      createHome = true;
      home = dataDir;
      uid = config.ids.uids.terraria;
    };

    groups.terraria.gid = config.ids.gids.terraria;
  };

  systemd = {
    services.terraria = {
      wantedBy = [ "multi-user.target" ];
      after = [
        "network.target"
        config.systemd.sockets.terraria.name
      ];
      requires = [ config.systemd.sockets.terraria.name ];
      partOf = [ config.systemd.sockets.terraria.name ];

      script = "${pkgs.terraria-server}/bin/TerrariaServer ${toString args}";

      serviceConfig = {
        Type = "simple";
        StandardInput = "socket";
        StandardOutput = "journal";
        StandardError = "journal";
        Restart = "on-abort";

        User = "terraria";
        Group = "terraria";
        UMask = "007";

        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = dataDir;
      };
    };

    sockets.terraria = {
      requires = [ config.systemd.services.terraria.name ];
      partOf = [ config.systemd.services.terraria.name ];

      socketConfig = {
        ListenFIFO = "/run/terraria/world.stdin";
        SocketUser = "terraria";
        SocketGroup = "terraria";
        SocketMode = "0660";
        RemoveOnStop = true;
        FlushPending = true;
      };
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ port ];
    allowedUDPPorts = [ port ];
  };
}
