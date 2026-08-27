{
  config,
  lib,
  libJail,
  osConfig,
  pkgs,
  ...
}:
let
  packages = import ./packages.nix { inherit pkgs; };

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

    skills = "${packages.ponytail}/skills";
  };
}
