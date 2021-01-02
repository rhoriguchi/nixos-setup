{ pkgs, ... }: {
  home-manager.users.rhoriguchi.programs.vscode = {
    enable = true;

    package = pkgs.vscode;

    userSettings = {
      "editor.renderIndentGuides" = false;
      "editor.renderWhitespace" = "trailing";
      "editor.suggestSelection" = "first";
      "editor.wordBasedSuggestionsMode" = "allDocuments";
      "explorer.compactFolders" = false;
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
      "latex-workshop.view.pdf.viewer" = "tab";
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

    extensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "auto-close-tag";
        publisher = "formulahendry";
        version = "0.5.9";
        sha256 = "1bq2c83w5mwm0l4lb8agbl5z1dknf4fmbf13ybx6hclkb0acljvw";
      }
      {
        name = "auto-rename-tag";
        publisher = "formulahendry";
        version = "0.1.5";
        sha256 = "1ic3nxpcan8wwwzwm099plkn7fdy0zz2575rh4znc4sqgcqywh2i";
      }
      {
        name = "beautify";
        publisher = "HookyQR";
        version = "1.5.0";
        sha256 = "1c0kfavdwgwham92xrh0gnyxkrl9qlkpv39l1yhrldn8vd10fj5i";
      }
      {
        name = "bracket-pair-colorizer";
        publisher = "CoenraadS";
        version = "1.0.61";
        sha256 = "0r3bfp8kvhf9zpbiil7acx7zain26grk133f0r0syxqgml12i652";
      }
      {
        name = "code-runner";
        publisher = "formulahendry";
        version = "0.11.1";
        sha256 = "1y7rb0sg2vy7pyqn05pj4hign2sqxj63bpmgbp5fxvf5ygnm702g";
      }
      {
        name = "color-highlight";
        publisher = "naumovs";
        version = "2.3.0";
        sha256 = "1syzf43ws343z911fnhrlbzbx70gdn930q67yqkf6g0mj8lf2za2";
      }
      {
        name = "copy-relative-path";
        publisher = "alexdima";
        version = "0.0.2";
        sha256 = "06g601n9d6wyyiz659w60phgm011gn9jj5fy0gf5wpi2bljk3vcn";
      }
      {
        name = "git-indicators";
        publisher = "lamartire";
        version = "2.1.2";
        sha256 = "13bayq2nl3q0rzwq9bqc5jw13l71aq8laxi32bcab4xnw3pcamky";
      }
      {
        name = "git-project-manager";
        publisher = "felipecaputo";
        version = "1.7.1";
        sha256 = "1pghgzs89qwp9bx6z749z6a00pfqm2416n4lmna6dhpk5671hah9";
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
        name = "latex-workshop";
        publisher = "James-Yu";
        version = "8.15.0";
        sha256 = "0v4pq3l6g4dr1qvnmgsw148061lngwmk3zm12q0kggx85blki12d";
      }
      {
        name = "material-icon-theme";
        publisher = "PKief";
        version = "4.4.0";
        sha256 = "1m9mis59j9xnf1zvh67p5rhayaa9qxjiw9iw847nyl9vsy73w8ya";
      }
      {
        name = "Nix";
        publisher = "bbenoist";
        version = "1.0.1";
        sha256 = "0zd0n9f5z1f0ckzfjr38xw2zzmcxg1gjrava7yahg5cvdcw6l35b";
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
        name = "remote-containers";
        publisher = "ms-vscode-remote";
        version = "0.148.1";
        sha256 = "0689qn2a93vv71k2gr0g7l5c6y94h8ffsczhyiff452dh9mcfvnk";
      }
      {
        name = "scriptcsRunner";
        publisher = "filipw";
        version = "0.1.0";
        sha256 = "0l0923aqr8hkkvn9wpwjrc7d6c39y4cwcqk9sbih8fcy2g245sal";
      }
      {
        name = "sort-lines";
        publisher = "Tyriar";
        version = "1.9.0";
        sha256 = "0l4wibsjnlbzbrl1wcj18vnm1q4ygvxmh347jvzziv8f1l790qjl";
      }
      {
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
        name = "vscode-docker";
        publisher = "ms-azuretools";
        version = "1.8.1";
        sha256 = "08691mwb3kgmk5fnjpw1g3a5i7qwalw1yrv2skm519wh62w6nmw8";
      }
      {
        name = "vscode-fileutils";
        publisher = "sleistner";
        version = "3.4.2";
        sha256 = "1w3radmiv9amcl76n5zkalvfjq84p1y3fnf7ww3zpjd82iihzpbj";
      }
      {
        name = "vscode-github";
        publisher = "KnisterPeter";
        version = "0.30.4";
        sha256 = "0wcl2ilndayfmvb0ff9p20dcrp01yga4bc2nc3pww1immw4y1jim";
      }
      {
        name = "vscode-lombok";
        publisher = "GabrielBB";
        version = "1.0.1";
        sha256 = "1hc7p7an3yd2ssq1laixr0z8cn9yz7aq25hdw6k2fakgklzis6y6";
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
        name = "vscode-xml";
        publisher = "redhat";
        version = "0.14.0";
        sha256 = "04rk7gy660saccqn89m93dzw3hkpkdj66sbsk1wb125bfignmq4c";
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
