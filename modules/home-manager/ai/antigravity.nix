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

  # TODO does not work
  home.file.".gemini/antigravity-cli/hooks.json" = lib.mkIf config.programs.antigravity-cli.enable ({
    source = pkgs.writers.writeJSON "hooks.json" {
      "sync-git-crypt-to-geminiignore" = {
        PreInvocation = [
          {
            type = "command";
            timeout = 5;
            command = pkgs.writers.writeBash "sync-git-crypt-to-geminiignore.sh" ''
              git_root=$(${config.programs.git.package}/bin/git rev-parse --show-toplevel 2>/dev/null)

              if [ -n "$git_root" ]; then
                encrypted_files=$(${pkgs.git-crypt}/bin/git-crypt status 2>/dev/null |
                  ${pkgs.gnugrep}/bin/grep -v 'not encrypted' |
                  ${pkgs.gawk}/bin/awk '{print $2}')

                if [ -n "$encrypted_files" ]; then
                  echo "$encrypted_files" > "$git_root/.geminiignore"
                fi
              fi
            '';
          }
        ];
      };
    };
  });
}
