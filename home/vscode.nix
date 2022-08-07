{ pkgs, lib, colors, ... }: {
  fonts.fontconfig.enable = true;
  home.packages = [ pkgs.nerdfonts ];

  programs.zsh.shellAliases.vscode = "code";

  programs.vscode = {
    enable = true;

    mutableExtensionsDir = false;
    extensions = [
      pkgs.vscode-extensions.adpyke.codesnap
      pkgs.vscode-extensions.alexdima.copy-relative-path
      pkgs.vscode-extensions.bbenoist.nix
      pkgs.vscode-extensions.davidanson.vscode-markdownlint
      pkgs.vscode-extensions.dotjoshjohnson.xml
      pkgs.vscode-extensions.eamodio.gitlens
      pkgs.vscode-extensions.esbenp.prettier-vscode
      pkgs.vscode-extensions.formulahendry.auto-close-tag
      pkgs.vscode-extensions.formulahendry.auto-rename-tag
      pkgs.vscode-extensions.gruntfuggly.todo-tree
      pkgs.vscode-extensions.hashicorp.terraform
      pkgs.vscode-extensions.ibm.output-colorizer
      pkgs.vscode-extensions.jock.svg
      pkgs.vscode-extensions.johnpapa.vscode-peacock
      pkgs.vscode-extensions.kamikillerto.vscode-colorize
      pkgs.vscode-extensions.ms-azuretools.vscode-docker
      pkgs.vscode-extensions.ms-dotnettools.csharp
      pkgs.vscode-extensions.ms-python.python
      pkgs.vscode-extensions.ms-vscode.PowerShell
      pkgs.vscode-extensions.pkief.material-icon-theme
      pkgs.vscode-extensions.redhat.java
      pkgs.vscode-extensions.redhat.vscode-yaml
      pkgs.vscode-extensions.rubymaniac.vscode-paste-and-indent
      pkgs.vscode-extensions.ryu1kn.partial-diff
      pkgs.vscode-extensions.spywhere.guides
      pkgs.vscode-extensions.streetsidesoftware.code-spell-checker
      pkgs.vscode-extensions.tomoki1207.pdf
      pkgs.vscode-extensions.tyriar.sort-lines
      pkgs.vscode-extensions.vincaslt.highlight-matching-tag
      pkgs.vscode-extensions.wholroyd.jinja
      pkgs.vscode-extensions.wix.vscode-import-cost
    ];

    userTasks = {
      "version" = "2.0.0";
      "tasks" = [
        {
          "type" = "shell";
          "label" = "deadnix";
          "command" = ''
            find ''${workspaceFolder} -name "*.nix" -and ! -name "hardware-configuration.nix" | xargs ${pkgs.deadnix}/bin/deadnix'';
          "presentation" = {
            "clear" = true;
            "focus" = true;
            "panel" = "dedicated";
            "reveal" = "always";
          };
          "group" = "none";
          "problemMatcher" = [ ];
        }
        {
          "type" = "shell";
          "label" = "nixfmt";
          "command" = ''find ''${workspaceFolder} -name "*.nix" | xargs ${pkgs.haskellPackages.nixfmt}/bin/nixfmt --width=140'';
          "presentation" = {
            "clear" = true;
            "close" = true;
            "panel" = "dedicated";
            "reveal" = "silent";
          };
          "group" = "none";
          "problemMatcher" = [ ];
        }
      ];
    };

    userSettings = {
      "colorize.include" = [ "*" ];
      "cSpell.enableFiletypes" = [ "nix" "terraform" ];
      "cSpell.userWords" = [ "horiguchi" "rhoriguchi" ];
      "editor.bracketPairColorization.enabled" = true;
      "editor.fontFamily" = "JetBrainsMono Nerd Font";
      "editor.guides.bracketPairs" = true;
      "editor.linkedEditing" = true;
      "editor.renderWhitespace" = "trailing";
      "editor.suggestSelection" = "first";
      "editor.tokenColorCustomizations".comments = "#767676";
      "editor.unicodeHighlight.includeComments" = true;
      "editor.wordBasedSuggestionsMode" = "allDocuments";
      "explorer.compactFolders" = false;
      "explorer.confirmDelete" = false;
      "explorer.fileNesting.enabled" = true;
      "explorer.fileNesting.expand" = false;
      "extensions.autoUpdate" = false;
      "files.associations" = {
        "*.hcl" = "terraform";
        "*.jinja2" = "jinja";
      };
      "files.autoSave" = "onFocusChange";
      "files.exclude" = {
        "**/.classpath" = true;
        "**/.DS_Store" = true;
        "**/.factorypath" = true;
        "**/.git-crypt" = true;
        "**/.git" = true;
        "**/.hg" = true;
        "**/.idea" = true;
        "**/.project" = true;
        "**/.settings" = true;
        "**/.svn" = true;
        "**/.vscode" = true;
        "**/CVS" = true;
      };
      "files.insertFinalNewline" = true;
      "files.trimTrailingWhitespace" = true;
      "gitlens.defaultDateFormat" = "DD.MM.YYYY HH:MM";
      "gitlens.defaultDateShortFormat" = "DD.MM.YYYY";
      "importCost.javascriptExtensions" = [ "\\.jsx?$" "\\.tsx?$" ];
      "peacock.affectActivityBar" = true;
      "peacock.affectStatusBar" = true;
      "peacock.affectTitleBar" = false;
      "peacock.elementAdjustments" = {
        activityBar = "none";
        statusBar = "darken";
        titleBar = "none";
      };
      "peacock.favoriteColors" = [
        {
          name = "GitLab";
          value = "#FA7035";
        }
        {
          name = "NixOS";
          value = "#82BFE0";
        }
      ] ++ lib.sort (a: b: a.name < b.name) (lib.attrsets.mapAttrsToList (key: value: {
        name = let
          head = lib.toUpper (lib.substring 0 1 key);
          tail = lib.substring 1 (lib.stringLength key) key;
        in lib.concatStrings [ head tail ];
        inherit value;
      }) colors.normal);
      "peacock.showColorInStatusBar" = false;
      "prettier.arrowParens" = "always";
      "prettier.printWidth" = 120;
      "prettier.singleQuote" = true;
      "prettier.trailingComma" = "es5";
      "security.workspace.trust.enabled" = false;
      "svg.preview.autoShow" = true;
      "telemetry.telemetryLevel" = "off";
      "terminal.external.linuxExec" = "${pkgs.alacritty}/bin/alacritty";
      "todo-tree.highlights.customHighlight" = {
        "[ ]" = {
          "hideFromStatusBar" = true;
          "hideFromTree" = true;
          "type" = "none";
        };
        "[x]" = {
          "hideFromStatusBar" = true;
          "hideFromTree" = true;
          "type" = "none";
        };
      };
      "todo-tree.highlights.defaultHighlight" = {
        fontWeight = "bold";
        foreground = "${colors.normal.green}";
        type = "text-and-comment";
      };
      "todo-tree.general.tags" = [ "[ ]" "[x]" "BUG" "FIXME" "HACK" "TODO" "XXX" ];
      "todo-tree.regex.regexCaseSensitive" = false;
      "todo-tree.tree.expanded" = true;
      "todo-tree.tree.showCountsInTree" = true;
      "typescript.inlayHints.parameterNames.enabled" = "all";
      "update.mode" = "none";
      "window.autoDetectColorScheme" = true;
      "window.newWindowDimensions" = "maximized";
      "window.openFoldersInNewWindow" = "on";
      "window.restoreFullscreen" = false;
      "window.zoomLevel" = 0;
      "workbench.colorTheme" = "Default Light+";
      "workbench.editor.highlightModifiedTabs" = true;
      "workbench.editor.untitled.hint" = "hidden";
      "workbench.editorAssociations"."*.md" = "vscode.markdown.preview.editor";
      "workbench.iconTheme" = "material-icon-theme";
      "workbench.list.smoothScrolling" = true;
      "workbench.preferredDarkColorTheme" = "Default Dark+";
      "workbench.preferredLightColorTheme" = "Default Light+";
      "workbench.startupEditor" = "none";
      "[html]"."editor.defaultFormatter" = "vscode.html-language-features";
      "[javascript]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
      "[json]"."editor.defaultFormatter" = "vscode.json-language-features";
      "[jsonc]"."editor.defaultFormatter" = "vscode.json-language-features";
      "[latex]" = {
        "editor.wordWrap" = "wordWrapColumn";
        "editor.wordWrapColumn" = 120;
      };
      "[nix]"."editor.tabSize" = 2;
      "[terraform]"."editor.tabSize" = 2;
      "[typescript]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
      "[typescriptreact]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
      "[yaml]" = {
        "editor.defaultFormatter" = "redhat.vscode-yaml";
        "editor.tabSize" = 2;
      };
    };

    keybindings = [
      {
        command = "editor.action.commentLine";
        key = "ctrl+numpad_divide";
        when = "editorTextFocus && !editorReadonly";
      }
      {
        command = "editor.action.commentLine";
        key = "ctrl+/";
        when = "editorTextFocus && !editorReadonly";
      }
      {
        command = "editor.action.copyLinesDownAction";
        key = "ctrl+d";
        when = "editorTextFocus && !editorReadonly";
      }
      {
        command = "workbench.action.terminal.focusFind";
        key = "ctrl+shift+f";
        when =
          "terminalFindFocused && terminalHasBeenCreated || terminalFindFocused && terminalProcessSupported || terminalFocus && terminalHasBeenCreated || terminalFocus && terminalProcessSupported";
      }
      {
        command = "workbench.action.terminal.focusNext";
        key = "ctrl+shift+down";
        when =
          "terminalFocus && terminalHasBeenCreated && !terminalEditorFocus || terminalFocus && terminalProcessSupported && !terminalEditorFocus";
      }
      {
        command = "workbench.action.terminal.focusNextPane";
        key = "ctrl+shift+right";
        when = "terminalFocus && terminalHasBeenCreated || terminalFocus && terminalProcessSupported";
      }
      {
        command = "workbench.action.terminal.focusPrevious";
        key = "ctrl+shift+up";
        when =
          "terminalFocus && terminalHasBeenCreated && !terminalEditorFocus || terminalFocus && terminalProcessSupported && !terminalEditorFocus";
      }
      {
        command = "workbench.action.terminal.focusPreviousPane";
        key = "ctrl+shift+left";
        when = "terminalFocus && terminalHasBeenCreated || terminalFocus && terminalProcessSupported";
      }
      {
        command = "workbench.action.terminal.new";
        key = "ctrl+shift+t";
      }
      {
        command = "workbench.action.terminal.split";
        key = "ctrl+shift+t";
        when = "terminalFocus && terminalProcessSupported || terminalFocus && terminalWebExtensionContributedProfile";
      }

      {
        command = "-workbench.action.terminal.openNativeConsole";
        key = "";
      }
    ];
  };
}
