{
  config,
  lib,
  libJail,
  osConfig,
  pkgs,
  ...
}:
let
  ponytailBandDir = "${config.xdg.configHome}/ponytail/band";

  agentJail = import ./jail.nix {
    inherit
      config
      lib
      libJail
      osConfig
      pkgs
      ;
  };

  claudeSandboxed = agentJail.mkJailedAgent {
    package = pkgs.llm-agents.claude-code;

    extraPermissions = [
      (agentJail.combinators.try-readwrite config.programs.claude-code.configDir)
      (agentJail.combinators.try-readwrite "${config.home.homeDirectory}/.claude.json")

      (agentJail.combinators.add-runtime ''
        mkdir -p "${ponytailBandDir}"
        RUNTIME_ARGS+=(--bind "${ponytailBandDir}" "${ponytailBandDir}")
      '')
    ];
  };
in
{
  programs = {
    claude-code = {
      enable = true;

      package = claudeSandboxed;

      enableMcpIntegration = true;

      plugins.ponytail = pkgs.skills.ponytail;

      skills.skill-creator = "${pkgs.skills.skill-creator}/skill-creator";

      settings = {
        # https://code.claude.com/docs/en/data-usage#telemetry-services
        env = {
          DISABLE_ERROR_REPORTING = "1";
          DISABLE_TELEMETRY = "1";
        };

        enableArtifact = false;

        promptSuggestionEnabled = false;

        attribution = {
          commits = false;
          pullRequests = false;
        };
      };
    };

    git.ignores = [
      ".claude/settings.local.json"
    ];
  };
}
