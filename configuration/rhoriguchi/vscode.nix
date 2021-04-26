{ pkgs, ... }: {
  fonts.fonts = [ pkgs.jetbrains-mono ];

  home-manager.users.rhoriguchi.programs.vscode = {
    enable = true;

    extensions = [
      pkgs.vscode-extensions.alexdima.copy-relative-path
      pkgs.vscode-extensions.antfu.icons-carbon
      pkgs.vscode-extensions.bbenoist.Nix
      pkgs.vscode-extensions.brettm12345.nixfmt-vscode
      pkgs.vscode-extensions.coenraads.bracket-pair-colorizer-2
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
      pkgs.vscode-extensions.ms-azuretools.vscode-docker
      pkgs.vscode-extensions.ms-dotnettools.csharp
      pkgs.vscode-extensions.ms-python.python
      pkgs.vscode-extensions.naumovs.color-highlight
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
    ];

    userSettings = {
      "cSpell.enableFiletypes" = [ "nix" "terraform" ];
      "cSpell.userWords" = [ "rhoriguchi" ];
      "editor.fontFamily" = "JetBrains Mono";
      "editor.linkedEditing" = true;
      "editor.renderIndentGuides" = false;
      "editor.renderWhitespace" = "trailing";
      "editor.suggestSelection" = "first";
      "editor.wordBasedSuggestionsMode" = "allDocuments";
      "explorer.compactFolders" = false;
      "explorer.confirmDelete" = false;
      "extensions.autoUpdate" = false;
      "files.associations"."*.jinja2" = "jinja";
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
      "gitlens.advanced.messages"."suppressShowKeyBindingsNotice" = true;
      "gitlens.defaultDateFormat" = "DD.MM.YYYY HH:MM";
      "gitlens.defaultDateShortFormat" = "DD.MM.YYYY";
      "prettier.arrowParens" = "always";
      "prettier.printWidth" = 120;
      "prettier.singleQuote" = true;
      "prettier.trailingComma" = "es5";
      "svg.preview.autoShow" = true;
      "telemetry.enableTelemetry" = false;
      "terminal.external.linuxExec" = "${pkgs.alacritty}/bin/alacritty";
      "terraform.languageServer" = {
        "args" = [ "serve" ];
        "external" = true;
      };
      "todo-tree.highlights.customHighlight" = {
        "[ ]"."background" = "#FF413680";
        "[X]"."background" = "#2ECC4080";
      };
      "todo-tree.highlights.defaultHighlight" = {
        "fontWeight" = "bold";
        "foreground" = "green";
        "type" = "tag-and-comment";
      };
      "todo-tree.general.tags" = [ "[ ]" "[x]" "BUG" "FIXME" "HACK" "TODO" "XXX" ];
      "todo-tree.regex.regexCaseSensitive" = false;
      "todo-tree.tree.expanded" = true;
      "todo-tree.tree.showCountsInTree" = true;
      "todo-tree.tree.showScanModeButton" = false;
      "update.mode" = "none";
      "window.newWindowDimensions" = "maximized";
      "window.openFoldersInNewWindow" = "on";
      "window.restoreFullscreen" = false;
      "window.zoomLevel" = 0;
      "workbench.colorTheme" = "Visual Studio 2019 Light";
      "workbench.iconTheme" = "material-icon-theme";
      "workbench.list.smoothScrolling" = true;
      "workbench.productIconTheme" = "icons-carbon";
      "workbench.startupEditor" = "none";
      "[html]" = { "editor.defaultFormatter" = "vscode.html-language-features"; };
      "[json]" = { "editor.defaultFormatter" = "vscode.json-language-features"; };
      "[jsonc]" = { "editor.defaultFormatter" = "vscode.json-language-features"; };
      "[latex]" = {
        "editor.wordWrap" = "wordWrapColumn";
        "editor.wordWrapColumn" = 120;
      };
      "[nix]"."editor.tabSize" = 2;
      "[yaml]" = {
        "editor.defaultFormatter" = "redhat.vscode-yaml";
        "editor.tabSize" = 2;
      };
    };

    keybindings = [
      {
        key = "ctrl+d";
        command = "editor.action.copyLinesDownAction";
        when = "editorTextFocus && !editorReadonly";
      }
      {
        key = "ctrl+numpad_divide";
        command = "editor.action.commentLine";
        when = "editorTextFocus && !editorReadonly";
      }
    ];
  };
}
