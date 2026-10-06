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

  antigravitySandboxed = agentJail.mkJailedAgent {
    package = pkgs.llm-agents.antigravity-cli;

    extraPermissions = [
      (agentJail.combinators.try-readwrite "${config.home.homeDirectory}/.gemini")

      (agentJail.combinators.dbus { talk = [ "org.freedesktop.secrets" ]; })
    ];
  };
in
{
  programs.antigravity-cli = {
    enable = true;

    package = antigravitySandboxed;

    enableMcpIntegration = true;

    settings = {
      enableTelemetry = false;
      showFeedbackSurvey = false;
    };

    skills = pkgs.symlinkJoin {
      name = "antigravity-cli-skills";
      paths = [
        "${pkgs.skills.ponytail}/skills"
      ];
    };
  };
}
