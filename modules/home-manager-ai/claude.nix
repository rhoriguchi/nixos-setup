{
  config,
  lib,
  libJail,
  osConfig,
  pkgs,
  ...
}:
let
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
        enableTelemetry = false;
        showFeedbackSurvey = false;

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
