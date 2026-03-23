{ colors, pkgs, ... }:
{
  programs = {
    vscode.extensions = [ pkgs.vscode-extensions.Google.gemini-cli-vscode-ide-companion ];

    gemini-cli = {
      enable = true;

      package = pkgs.llm-agents.gemini-cli;

      settings = {
        ide = {
          enabled = true;
          hasSeenNudge = true;
        };

        security.auth.selectedType = "oauth-personal";

        tools = {
          shell.showColor = true;

          allowed = map (command: "run_shell_command(${command})") [ ];
        };

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
                added = colors.normal.green;
                removed = colors.normal.red;
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
