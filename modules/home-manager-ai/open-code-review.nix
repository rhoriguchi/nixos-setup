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
    package = pkgs.llm-agents.open-code-review;

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
        models = [
          "gemma4:12b"
        ];
      };

      mcp_servers = mcpServers;
    };
  };
}
