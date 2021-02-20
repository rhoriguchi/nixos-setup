{ pkgs, ... }: {
  home-manager.users.rhoriguchi.programs.vscode = {
    enable = true;

    # TODO figure out why this can't be removed, this is the default
    package = pkgs.vscode;

    userSettings = {
      "cSpell.enableFiletypes" = [ "nix" "terraform" ];
      "cSpell.userWords" = [ "rhoriguchi" ];
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
      "todo-tree.highlights.defaultHighlight" = {
        "fontWeight" = "bold";
        "foreground" = "green";
        "type" = "tag-and-comment";
      };
      "todo-tree.regex.regex" =
        "((//|#|%|<!--|;|/\\*|^)\\s*($TAGS)|^\\s*- \\[ \\])";
      "todo-tree.regex.regexCaseSensitive" = false;
      "todo-tree.tree.expanded" = true;
      "todo-tree.tree.showCountsInTree" = true;
      "todo-tree.tree.showScanModeButton" = false;
      "update.mode" = "none";
      "vsintellicode.modify.editor.suggestSelection" =
        "automaticallyOverrodeDefaultValue";
      "window.openFoldersInNewWindow" = "on";
      "window.zoomLevel" = 0;
      "workbench.colorTheme" = "Visual Studio 2019 Light";
      "workbench.iconTheme" = "material-icon-theme";
      "workbench.list.smoothScrolling" = true;
      "workbench.startupEditor" = "none";
      "[html]" = {
        "editor.defaultFormatter" = "vscode.html-language-features";
      };
      "[json]" = {
        "editor.defaultFormatter" = "vscode.json-language-features";
      };
      "[jsonc]" = {
        "editor.defaultFormatter" = "vscode.json-language-features";
      };
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

    extensions = (with pkgs.vscode-extensions; [
      alexdima.copy-relative-path
      bbenoist.Nix
      brettm12345.nixfmt-vscode
      coenraads.bracket-pair-colorizer-2
      davidanson.vscode-markdownlint
      eamodio.gitlens
      esbenp.prettier-vscode
      formulahendry.auto-close-tag
      formulahendry.auto-rename-tag
      gruntfuggly.todo-tree
      hashicorp.terraform
      ibm.output-colorizer
      jock.svg
      ms-azuretools.vscode-docker
      ms-python.python
      naumovs.color-highlight
      pkief.material-icon-theme
      redhat.vscode-yaml
      rubymaniac.vscode-paste-and-indent
      ryu1kn.partial-diff
      spywhere.guides
      streetsidesoftware.code-spell-checker
      tomoki1207.pdf
      tyriar.sort-lines
      vincaslt.highlight-matching-tag
      wholroyd.jinja
    ]) ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      # TODO create pull request to add all missing
      # TODO maybe add? https://marketplace.visualstudio.com/items?itemName=jnoortheen.nix-ide
      {
        # TODO fails https://marketplace.visualstudio.com/items?itemName=ms-dotnettools.csharp
        # Installing C# dependencies...
        # Platform: linux, x86_64, name=nixos, version=21.03pre262347.257cbbcd3ab

        # Failed at stage: touchBeginFile
        # Error: EROFS: read-only file system, mkdir '/home/rhoriguchi/.vscode/extensions/ms-dotnettools.csharp/.omnisharp'

        # https://github.com/NixOS/nixpkgs/pull/100181
        name = "csharp";
        publisher = "ms-dotnettools";
        version = "1.23.8";
        sha256 = "1lb3y7fs2c6kbygjfls7lc3dc8snlspkfa15mp49srhc0kbxcgff";
      }
      {
        # TODO figure out if java jdk is required?
        name = "java";
        publisher = "redhat";
        version = "0.74.0";
        sha256 = "0d5rp1p9v5yxq6sadlsa87lg257k43jgsx4s5zb8pwj63lh728h1";
      }
      {
        # TODO has issues "Couldn't download IntelliCode model. Please check your network connectivity or firewall settings."
        name = "vscodeintellicode";
        publisher = "VisualStudioExptTeam";
        version = "1.2.10";
        sha256 = "1l980w4r18613hzwvqgnzm9csi72r9ngyzl94p39rllpiqy7xrhi";
      }
    ];
  };
}
