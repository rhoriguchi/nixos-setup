{ pkgs, ... }: {
  home-manager.users.rhoriguchi.programs.vscode = {
    enable = true;

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
      "files.autoSave" = "onFocusChange";
      "files.exclude" = {
        "**/.classpath" = true;
        "**/.DS_Store" = true;
        "**/.factorypath" = true;
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
      "gitlens.advanced.messages" = { "suppressShowKeyBindingsNotice" = true; };
      "gitlens.defaultDateFormat" = "DD.MM.YYYY HH:MM";
      "gitlens.defaultDateShortFormat" = "DD.MM.YYYY";
      "prettier.arrowParens" = "always";
      "prettier.printWidth" = 120;
      "prettier.singleQuote" = true;
      "prettier.trailingComma" = "es5";
      "svg.preview.autoShow" = true;
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
      "[nix]" = { "editor.tabSize" = 2; };
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
      esbenp.prettier-vscode
      formulahendry.auto-close-tag
      formulahendry.auto-rename-tag
      ibm.output-colorizer
      ms-azuretools.vscode-docker
      ms-python.python
      naumovs.color-highlight
      pkief.material-icon-theme
      redhat.vscode-yaml
      ryu1kn.partial-diff
      tyriar.sort-lines
      vincaslt.highlight-matching-tag
    ]) ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      # TODO create pull request to add all missing
      {
        name = "beautify";
        publisher = "HookyQR";
        version = "1.5.0";
        sha256 = "1c0kfavdwgwham92xrh0gnyxkrl9qlkpv39l1yhrldn8vd10fj5i";
      }
      {
        name = "code-spell-checker";
        publisher = "streetsidesoftware";
        version = "1.10.2";
        sha256 = "1ll046rf5dyc7294nbxqk5ya56g2bzqnmxyciqpz2w5x7j75rjib";
      }
      # TODO fails https://marketplace.visualstudio.com/items?itemName=ms-dotnettools.csharp
      # Installing C# dependencies...
      # Platform: linux, x86_64, name=nixos, version=21.03pre262347.257cbbcd3ab

      # Failed at stage: touchBeginFile
      # Error: EROFS: read-only file system, mkdir '/home/rhoriguchi/.vscode/extensions/ms-dotnettools.csharp/.omnisharp'
      {
        # https://github.com/NixOS/nixpkgs/pull/100181
        name = "csharp";
        publisher = "ms-dotnettools";
        version = "1.23.8";
        sha256 = "1lb3y7fs2c6kbygjfls7lc3dc8snlspkfa15mp49srhc0kbxcgff";
      }
      {
        name = "gitlens";
        publisher = "eamodio";
        version = "11.0.6";
        sha256 = "0qlaq7hn3m73rx9bmbzz3rc7khg0kw948z2j4rd8gdmmryy217yw";
      }
      {
        name = "guides";
        publisher = "spywhere";
        version = "0.9.3";
        sha256 = "1kvsj085w1xax6fg0kvsj1cizqh86i0pkzpwi0sbfvmcq21i6ghn";
      }
      {
        name = "path-intellisense";
        publisher = "christian-kohler";
        version = "2.3.0";
        sha256 = "1wyp3k4gci1i64nrry12il6yflhki18gq2498z3nlsx4yi36jb3l";
      }
      {
        name = "svg";
        publisher = "jock";
        version = "1.4.4";
        sha256 = "0kn2ic7pgbd4rbvzpsxfwyiwxa1iy92l0h3jsppxc8gk8xbqm2nc";
      }
      # TODO add terraformm-ls https://github.com/hashicorp/terraform-ls
      {
        # https://github.com/NixOS/nixpkgs/pull/110505
        name = "terraform";
        publisher = "hashicorp";
        version = "2.3.0";
        sha256 = "0696q8nr6kb5q08295zvbqwj7lr98z18gz1chf0adgrh476zm6qq";
      }
      {
        name = "todo-tree";
        publisher = "Gruntfuggly";
        version = "0.0.196";
        sha256 = "1l4f290018f2p76q6hn2b2injps6wz65as7dm537wrsvsivyg2qz";
      }
      {
        name = "vscode-markdownlint";
        publisher = "DavidAnson";
        version = "0.38.0";
        sha256 = "0d6hbsjrx1j8wrmfnvdwsa7sci1brplgxwkmy6sp74va7zxfjnqv";
      }
      {
        name = "vscode-paste-and-indent";
        publisher = "Rubymaniac";
        version = "0.0.8";
        sha256 = "0fqwcvwq37ndms6vky8jjv0zliy6fpfkh8d9raq8hkinfxq6klgl";
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
