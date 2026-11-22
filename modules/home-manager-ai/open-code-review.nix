{
  config,
  lib,
  libJail,
  osConfig,
  pkgs,
  ...
}:
let
  format = pkgs.formats.json { };

  agentJail = import ./jail.nix {
    inherit
      config
      lib
      libJail
      osConfig
      pkgs
      ;
  };

  ocrSandboxed = agentJail.mkJailedAgent {
    package = pkgs.llm-agents.open-code-review.overrideAttrs (old: {
      nativeBuildInputs = old.nativeBuildInputs ++ [ pkgs.makeWrapper ];

      postFixup = (old.postFixup or "") + ''
        wrapProgram "$out/bin/ocr" --run ${lib.escapeShellArg ''
          case "''${1:-}" in
            review | scan)
              subcommand="$1"
              shift
              set -- "$subcommand" --timeout 0 --concurrency 1 "$@"
              ;;
          esac
        ''}
      '';
    });

    extraPermissions = [
      (agentJail.combinators.try-readwrite "${config.home.homeDirectory}/.opencodereview")
    ];
  };

  mcpServers = lib.optionalAttrs config.programs.mcp.enable (
    lib.pipe config.programs.mcp.servers [
      (lib.filterAttrs (_: server: lib.hm.mcp.resolveEnabled server != false))
      (lib.mapAttrs (
        name: server:
        lib.pipe server [
          (
            server:
            lib.hm.mcp.transformMcpServer {
              inherit server;
              exclude = [ "enabled" ];
              extraTransforms = [
                (lib.hm.mcp.wrapEnvFilesCommand { inherit pkgs name; })
                (server: if server.url != null then server // { type = "remote"; } else server)
              ];
            }
          )
          (
            server:
            if server ? env then
              server // { env = lib.mapAttrsToList (variable: value: "${variable}=${value}") server.env; }
            else
              server
          )
        ]
      ))
    ]
  );

  providerName = "ollama";
in
{
  home = {
    packages = [
      ocrSandboxed
    ];

    file.".opencodereview/config.json".source = format.generate "config.json" {
      provider = providerName;
      model = "gemma4:12b";

      custom_providers.${providerName} = {
        url = "http://xxlpitu-tier.tailnet:11434/v1";
        protocol = "openai";
        api_key = "ollama";
        timeout_sec = 60 * 30;
        models = [
          "gemma4:12b"
        ];
      };

      mcp_servers = mcpServers;
    };
  };
}
