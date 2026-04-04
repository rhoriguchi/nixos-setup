{
  colors,
  config,
  pkgs,
  secrets,
  ...
}:
{
  programs = {
    vscode.profiles.default.extensions = [
      pkgs.vscode-extensions.Google.gemini-cli-vscode-ide-companion
    ];

    gemini-cli = {
      enable = true;

      package = pkgs.llm-agents.gemini-cli;

      policies."run_shell_command".rule = map (command: {
        toolName = "run_shell_command";
        commandPrefix = command;
        decision = "allow";
        priority = 100;
      }) [ ];

      settings = {
        ide = {
          enabled = true;
          hasSeenNudge = true;
        };

        security.auth.selectedType = "oauth-personal";

        tools = {
          shell.showColor = true;
          enableHooks = true;
        };

        mcpServers = {
          github = {
            command = "${pkgs.github-mcp-server}/bin/github-mcp-server";
            args = [ "stdio" ];
            env.GITHUB_PERSONAL_ACCESS_TOKEN = secrets.gemini.mcpServers.github.accessToken;
          };

          nixos = {
            command = "${pkgs.mcp-nixos}/bin/mcp-nixos";
            args = [ "--" ];
          };
        };

        hooks.BeforeModel = [
          {
            matcher = "*";
            hooks = [
              {
                name = "sync-git-crypt-to-geminiignore";
                type = "command";
                command = pkgs.writeShellScript "sync-git-crypt-to-geminiignore.sh" ''
                  GIT_ROOT=$(${config.programs.git.package}/bin/git rev-parse --show-toplevel 2>/dev/null)

                  if [ -n "$GIT_ROOT" ]; then
                    ENCRYPTED_FILES=$(${pkgs.coreutils}/bin/timeout 5s ${pkgs.git-crypt}/bin/git-crypt status 2>/dev/null |
                      ${pkgs.gnugrep}/bin/grep -v 'not encrypted' |
                      ${pkgs.gawk}/bin/awk '{print $2}')

                    if [ -n "$ENCRYPTED_FILES" ]; then
                      echo "$ENCRYPTED_FILES" > "$GIT_ROOT/.geminiignore"
                    fi
                  fi
                '';
              }
            ];
          }
        ];

        ui = {
          hideBanner = true;
          showMemoryUsage = true;
          showModelInfoInChat = true;
          loadingPhrases = "off";

          theme = "Custom";
          customThemes.Custom = {
            name = "Custom";
            type = "custom";

            text = {
              primary = colors.normal.white;
              secondary = colors.extra.terminal.border;
              link = colors.normal.accent;
              accent = colors.normal.accent;
            };

            background = {
              primary = colors.extra.terminal.background;
              diff = {
                added = colors.extra.diff.added;
                removed = colors.extra.diff.removed;
              };
            };

            border = {
              default = colors.extra.terminal.border;
              focused = colors.normal.accent;
            };

            status = {
              success = colors.normal.green;
              warning = colors.normal.yellow;
              error = colors.normal.red;
            };

            ui = {
              comment = colors.extra.comment;
              # TODO figure out what this does and change
              symbol = colors.normal.blue;
              gradient = [ colors.normal.white ];
            };
          };
        };
      };
    };
  };
}
