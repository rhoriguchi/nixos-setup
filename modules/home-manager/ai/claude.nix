{
  config,
  pkgs,
  ...
}:
let
  packages = import ./packages.nix { inherit pkgs; };
in
{
  programs = {
    claude-code = {
      enable = true;

      package = pkgs.llm-agents.claude-code;

      enableMcpIntegration = true;

      plugins.ponytail = packages.ponytail;

      settings = {
        enableTelemetry = false;
        showFeedbackSurvey = false;

        hooks.PreToolUse = [
          {
            matcher = "Read|Edit|Write|MultiEdit|NotebookEdit";
            hooks = [
              {
                type = "command";
                command = "${config.programs.claude-code.configDir}/hooks/deny-git-crypt";
                timeout = 5;
              }
            ];
          }
        ];
      };

      hooks."deny-git-crypt" = "${pkgs.writers.writeBash "deny-git-crypt.sh" ''
        file_path=$(${pkgs.jq}/bin/jq -r '.tool_input.file_path // .tool_input.notebook_path // empty')

        if [ -z "$file_path" ]; then
          exit 0
        fi

        git_root=$(${config.programs.git.package}/bin/git -C "$(${pkgs.coreutils}/bin/dirname "$file_path")" rev-parse --show-toplevel 2>/dev/null) || exit 0
        rel_path=$(${pkgs.coreutils}/bin/realpath --relative-to="$git_root" "$file_path" 2>/dev/null) || exit 0

        encrypted_files=$(${pkgs.git-crypt}/bin/git-crypt status "$git_root" 2>/dev/null |
          ${pkgs.gnugrep}/bin/grep -v 'not encrypted' |
          ${pkgs.gawk}/bin/awk '{print $2}')

        if ${pkgs.gnugrep}/bin/grep -qxF "$rel_path" <<< "$encrypted_files"; then
          ${pkgs.jq}/bin/jq -n '{
            hookSpecificOutput: {
              hookEventName: "PreToolUse",
              permissionDecision: "deny",
              permissionDecisionReason: "File is git-crypt encrypted; Claude Code must not read or write it."
            }
          }'
        fi
      ''}";
    };

    git.ignores = [
      ".claude/settings.local.json"
    ];
  };
}
