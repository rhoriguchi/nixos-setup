{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.antigravity-cli = {
    enable = true;

    package = pkgs.llm-agents.antigravity-cli;

    enableMcpIntegration = true;

    settings = {
      enableTelemetry = false;
      showFeedbackSurvey = false;
    };
  };

  home.file.".gemini/antigravity-cli/hooks.json" = lib.mkIf config.programs.antigravity-cli.enable ({
    source = pkgs.writers.writeJSON "hooks.json" {
      "sync-git-crypt-to-geminiignore" = {
        PreInvocation = [
          {
            type = "command";
            timeout = 5;
            command = pkgs.writers.writeBash "sync-git-crypt-to-geminiignore.sh" ''
              GIT_ROOT=$(${config.programs.git.package}/bin/git rev-parse --show-toplevel 2>/dev/null)

              if [ -n "$GIT_ROOT" ]; then
                ENCRYPTED_FILES=$(${pkgs.git-crypt}/bin/git-crypt status 2>/dev/null |
                  ${pkgs.gnugrep}/bin/grep -v 'not encrypted' |
                  ${pkgs.gawk}/bin/awk '{print $2}')

                if [ -n "$ENCRYPTED_FILES" ]; then
                  echo "$ENCRYPTED_FILES" > "$GIT_ROOT/.geminiignore"
                fi
              fi
            '';
          }
        ];
      };
    };
  });
}
