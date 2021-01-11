{ pkgs, ... }: {
  home-manager.users.rhoriguchi.programs.vscode = {
    enable = true;

    package = pkgs.vscode;

    userSettings = {
      "cSpell.enableFiletypes" = [ "nix" "terraform" ];
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
      "[yaml]" = { "editor.tabSize" = 2; };
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
      bbenoist.Nix
      formulahendry.auto-close-tag
      ms-azuretools.vscode-docker
      ms-python.python
      naumovs.color-highlight
      pkief.material-icon-theme
      redhat.vscode-yaml
    ]) ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      # TODO create pull request to add all missing
      {
        name = "auto-rename-tag";
        publisher = "formulahendry";
        version = "0.1.6";
        sha256 = "0cqg9mxkyf41brjq2c764w42lzyn6ffphw6ciw7xnqk1h1x8wwbs";
      }
      {
        name = "beautify";
        publisher = "HookyQR";
        version = "1.5.0";
        sha256 = "1c0kfavdwgwham92xrh0gnyxkrl9qlkpv39l1yhrldn8vd10fj5i";
      }
      {
        name = "bracket-pair-colorizer-2";
        publisher = "CoenraadS";
        version = "0.2.0";
        sha256 = "0nppgfbmw0d089rka9cqs3sbd5260dhhiipmjfga3nar9vp87slh";
      }
      {
        name = "code-spell-checker";
        publisher = "streetsidesoftware";
        version = "1.10.2";
        sha256 = "1ll046rf5dyc7294nbxqk5ya56g2bzqnmxyciqpz2w5x7j75rjib";
      }
      {
        name = "copy-relative-path";
        publisher = "alexdima";
        version = "0.0.2";
        sha256 = "06g601n9d6wyyiz659w60phgm011gn9jj5fy0gf5wpi2bljk3vcn";
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
        name = "highlight-matching-tag";
        publisher = "vincaslt";
        version = "0.10.0";
        sha256 = "1albwz3lc9i20if77inm1ipwws8apigvx24rbag3d1h3p4vwda49";
      }
      {
        name = "nixfmt-vscode";
        publisher = "brettm12345";
        version = "0.0.1";
        sha256 = "07w35c69vk1l6vipnq3qfack36qcszqxn8j3v332bl0w6m02aa7k";
      }
      {
        name = "output-colorizer";
        publisher = "IBM";
        version = "0.1.2";
        sha256 = "0i9kpnlk3naycc7k8gmcxas3s06d67wxr3nnyv5hxmsnsx5sfvb7";
      }
      {
        name = "partial-diff";
        publisher = "ryu1kn";
        version = "1.4.1";
        sha256 = "1r4kg4slgxncdppr4fn7i5vfhvzcg26ljia2r97n6wvwn8534vs9";
      }
      {
        name = "path-intellisense";
        publisher = "christian-kohler";
        version = "2.3.0";
        sha256 = "1wyp3k4gci1i64nrry12il6yflhki18gq2498z3nlsx4yi36jb3l";
      }
      {
        name = "prettier-vscode";
        publisher = "esbenp";
        version = "5.8.0";
        sha256 = "0h7wc4pffyq1i8vpj4a5az02g2x04y7y1chilmcfmzg2w42xpby7";
      }
      {
        name = "sort-lines";
        publisher = "Tyriar";
        version = "1.9.0";
        sha256 = "0l4wibsjnlbzbrl1wcj18vnm1q4ygvxmh347jvzziv8f1l790qjl";
      }
      {
        # TODO add terraformm-ls https://github.com/hashicorp/terraform-ls
        name = "terraform";
        publisher = "hashicorp";
        version = "2.3.0";
        sha256 = "0696q8nr6kb5q08295zvbqwj7lr98z18gz1chf0adgrh476zm6qq";
      }
      {
        name = "todo-tree";
        publisher = "Gruntfuggly";
        version = "0.0.193";
        sha256 = "1cqp10pwyjic1p8ss1f5ng9igqmaqn10l65fpyka1dy2k90i1yay";
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
        name = "vscodeintellicode";
        publisher = "VisualStudioExptTeam";
        version = "1.2.10";
        sha256 = "1l980w4r18613hzwvqgnzm9csi72r9ngyzl94p39rllpiqy7xrhi";
      }
    ];
  };
}
