{
  config,
  lib,
  pkgs,
  ...
}:
let
  port = 8888;

  hindsight = pkgs.llm-agents.hindsight.overridePythonAttrs (old: {
    # Upstream leaves torch out of the default closure; the default `local`
    # embeddings/reranker providers need it.
    dependencies = old.dependencies ++ old.optional-dependencies.local-ml;
  });
in
{
  users = {
    users.hindsight = {
      isSystemUser = true;
      group = "hindsight";
      home = "/var/lib/hindsight";
    };

    groups.hindsight = { };
  };

  services.postgresql = {
    enable = true;

    extensions = ps: [ ps.pgvector ];

    ensureDatabases = [ "hindsight" ];
    ensureUsers = [
      {
        name = "hindsight";
        ensureDBOwnership = true;
      }
    ];
  };

  systemd.services = {
    # pgvector's control file is not `trusted`, so the unprivileged hindsight
    # role cannot CREATE EXTENSION. Hindsight skips CREATE when pg_extension
    # already lists it (hindsight_api/_pg_extensions.py:create_extension).
    # postgresql-setup runs as the postgres superuser after
    # ensureDatabases/ensureUsers.
    postgresql-setup.script = lib.mkAfter ''
      psql -d hindsight -v ON_ERROR_STOP=1 -c 'CREATE EXTENSION IF NOT EXISTS vector' -c 'CREATE EXTENSION IF NOT EXISTS pg_trgm'
    '';

    hindsight = {
      wantedBy = [ "multi-user.target" ];
      requires = [ config.systemd.services.postgresql-setup.name ];
      wants = [ config.systemd.services.ollama.name ];
      after = [
        config.systemd.services.postgresql-setup.name
        config.systemd.services.ollama.name
      ];

      environment = {
        HINDSIGHT_API_HOST = "0.0.0.0";
        HINDSIGHT_API_PORT = toString port;

        HINDSIGHT_API_DATABASE_URL = "postgresql://hindsight@/hindsight?host=/run/postgresql";

        HINDSIGHT_API_LLM_PROVIDER = "ollama";
        HINDSIGHT_API_LLM_BASE_URL = "http://127.0.0.1:${toString config.services.ollama.port}/v1";
        HINDSIGHT_API_LLM_MODEL = lib.head config.services.ollama.loadModels;
        HINDSIGHT_API_LLM_MAX_CONCURRENT = "1";

        # gemma4:12b needs 65-110s per reflect call and the unit serializes
        # calls (MAX_CONCURRENT=1), so mental-model refreshes
        # exceed the default 300s wall-clock limit and get cancelled, leaving
        # every mental model empty. Individual calls come close to the default
        # 120s LLM timeout too.
        HINDSIGHT_API_LLM_TIMEOUT = toString (60 * 5);
        HINDSIGHT_API_REFLECT_WALL_TIMEOUT = toString (60 * 30);

        # Unset by default, so a gemma4:12b consolidation call that loops (same
        # JSON array element repeated until the LLM timeout, ~28k tokens) blocks
        # the single ollama slot for minutes and starves retain. Valid outputs
        # stay under ~4k tokens; the cap turns a loop into a fast failure that
        # hindsight marks consolidation_failed_at and moves past.
        HINDSIGHT_API_CONSOLIDATION_MAX_COMPLETION_TOKENS = toString (1024 * 8);

        # Embeddings/reranker providers default to `local`.
        HF_HOME = "/var/cache/hindsight/huggingface";
        HOME = "/var/lib/hindsight";
      };

      serviceConfig = {
        ExecStart = lib.getExe hindsight;
        User = "hindsight";
        Group = "hindsight";
        StateDirectory = "hindsight";
        CacheDirectory = "hindsight";
        WorkingDirectory = "/var/lib/hindsight";
        Restart = "on-failure";
        RestartSec = 5;

        CapabilityBoundingSet = "";
        AmbientCapabilities = "";
        NoNewPrivileges = true;
        LockPersonality = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ProtectProc = "invisible";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        RemoveIPC = true;
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = [
          "@system-service"
          "~@privileged"
        ];
        UMask = "0077";
      };
    };
  };

  services.custom-netdata.extraPrometheusJobs = [
    {
      name = "Hindsight";
      url = "http://127.0.0.1:${toString port}/metrics";
    }
  ];

  networking.firewall.interfaces.${config.services.tailscale.interfaceName}.allowedTCPPorts = [
    port
  ];
}
