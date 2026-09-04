{
  colors,
  config,
  lib,
  libJail,
  osConfig,
  pkgs,
  ...
}:
let
  packages = import ./packages.nix { inherit pkgs; };
  jsonFormat = pkgs.formats.json { };
  yamlFormat = pkgs.formats.yaml { };

  homeDirectory = config.home.homeDirectory;

  agentJail = import ./jail.nix {
    inherit
      config
      lib
      libJail
      osConfig
      pkgs
      ;
  };

  ompSandboxed = agentJail.mkJailedAgent {
    package = pkgs.llm-agents.omp;

    extraPkgs = [
      # Used by omp's non-URL openPath() (export/share/login flows)
      pkgs.xdg-utils
    ];

    extraPermissions = [
      (agentJail.combinators.try-readwrite "${homeDirectory}/.omp")

      agentJail.combinators.open-urls-in-browser

      (agentJail.combinators.set-env "PUPPETEER_EXECUTABLE_PATH" "${pkgs.chromium}/bin/chromium")
    ];
  };

  mcpServers = lib.optionalAttrs config.programs.mcp.enable (
    lib.mapAttrs (
      _: server:
      lib.hm.mcp.transformMcpServer {
        inherit server;
        extraTransforms = [ lib.hm.mcp.addType ];
      }
    ) config.programs.mcp.servers
  );

  themeName = "home-manager";

  theme = {
    name = themeName;

    colors = {
      accent = colors.normal.accent;
      border = colors.extra.terminal.border;
      borderAccent = colors.normal.accent;
      borderMuted = colors.bright.black;
      success = colors.normal.green;
      error = colors.normal.red;
      warning = colors.normal.yellow;
      muted = colors.extra.comment;
      dim = colors.bright.black;
      text = "";
      thinkingText = colors.extra.comment;

      selectedBg = colors.extra.tmux.statusBackground;
      userMessageBg = colors.extra.tmux.statusBackground;
      customMessageBg = colors.extra.terminal.background;
      toolPendingBg = colors.extra.terminal.background;
      toolSuccessBg = colors.extra.diff.added;
      toolErrorBg = colors.extra.diff.removed;
      statusLineBg = colors.extra.tmux.statusBackground;

      userMessageText = "";
      customMessageText = "";
      customMessageLabel = colors.normal.accent;
      toolTitle = "";
      toolOutput = colors.extra.comment;

      mdHeading = colors.normal.accent;
      mdLink = colors.normal.accent;
      mdLinkUrl = colors.extra.comment;
      mdCode = colors.normal.cyan;
      mdCodeBlock = colors.normal.cyan;
      mdCodeBlockBorder = colors.extra.terminal.border;
      mdQuote = colors.extra.comment;
      mdQuoteBorder = colors.extra.terminal.border;
      mdHr = colors.extra.terminal.border;
      mdListBullet = colors.normal.accent;

      toolDiffAdded = colors.normal.green;
      toolDiffRemoved = colors.normal.red;
      toolDiffContext = colors.extra.comment;
      syntaxComment = colors.extra.comment;
      syntaxKeyword = colors.normal.white;
      syntaxFunction = colors.normal.blue;
      syntaxVariable = colors.normal.gray;
      syntaxString = colors.normal.green;
      syntaxNumber = colors.normal.white;
      syntaxType = colors.normal.cyan;
      syntaxOperator = colors.normal.white;
      syntaxPunctuation = colors.normal.gray;

      thinkingOff = colors.bright.black;
      thinkingMinimal = colors.extra.terminal.border;
      thinkingLow = colors.normal.cyan;
      thinkingMedium = colors.normal.blue;
      thinkingHigh = colors.normal.accent;
      thinkingXhigh = colors.normal.red;
      thinkingMax = colors.bright.red;
      bashMode = colors.normal.cyan;
      pythonMode = colors.normal.green;

      statusLineSep = colors.extra.terminal.border;
      statusLineModel = colors.normal.yellow;
      statusLinePath = colors.normal.accent;
      statusLineGitClean = colors.normal.green;
      statusLineGitDirty = colors.normal.yellow;
      statusLineContext = colors.normal.cyan;
      statusLineSpend = colors.normal.cyan;
      statusLineStaged = colors.normal.green;
      statusLineDirty = colors.normal.yellow;
      statusLineUntracked = colors.extra.comment;
      statusLineOutput = "";
      statusLineCost = colors.bright.yellow;
      statusLineSubagents = colors.bright.accent;
    };
  };
in
{
  home = {
    packages = [
      ompSandboxed
    ];

    file = {
      "${homeDirectory}/.omp/agent/config.yml".source = yamlFormat.generate "config.yml" {
        setupVersion = 2;

        theme = {
          dark = themeName;
          light = themeName;
        };

        advisor.enabled = true;
        display.showTokenUsage = true;
        github.enabled = true;
        startup.checkUpdate = false;

        dev.autoqa = false;

        modelRoles = {
          default = "anthropic/claude-sonnet-5";
          commit = "anthropic/claude-haiku-4-5";
          advisor = "google-antigravity/gemini-3.8-flash-medium";
        };

        skills.customDirectories = [
          "${packages.ponytail}/skills"
          "${packages.skill-creator}"
        ];
      };

      "${homeDirectory}/.omp/agent/themes/${themeName}.json".source =
        jsonFormat.generate "${themeName}.json" theme;
    }
    // lib.optionalAttrs (mcpServers != { }) {
      "${homeDirectory}/.omp/agent/mcp.json".source = jsonFormat.generate "mcp.json" {
        inherit mcpServers;
      };
    };
  };
}
