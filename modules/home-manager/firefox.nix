{
  colors,
  config,
  lib,
  pkgs,
  ...
}:
{
  home.sessionVariables.BROWSER = "${config.programs.firefox.package}/bin/firefox";

  programs = {
    vscode.profiles.default.userSettings."workbench.externalBrowser" =
      "${config.programs.firefox.package}/bin/firefox";

    firefox = {
      enable = true;

      profiles.default = {
        id = 0;

        extensions.packages = [
          pkgs.firefox-addons.bitwarden
          pkgs.firefox-addons.export-tabs-urls-and-titles
          pkgs.firefox-addons.grammarly
          pkgs.firefox-addons.multi-account-containers
          pkgs.firefox-addons.octolinker
          pkgs.firefox-addons.privacy-badger
          pkgs.firefox-addons.rabattcorner
          pkgs.firefox-addons.reddit-comment-collapser
          pkgs.firefox-addons.reddit-enhancement-suite
          pkgs.firefox-addons.tab-session-manager
          pkgs.firefox-addons.ublock-origin
          pkgs.firefox-addons.view-image
          pkgs.firefox-addons.wappalyzer
        ];

        search = {
          force = true;

          default = "google-custom";
          privateDefault = "google-custom";
          order = [ "google-custom" ];

          engines = {
            google-custom = {
              name = "Google (Custom)";
              iconMapObj."16" = "https://www.google.com/favicon.ico";
              definedAliases = [ "g" ];

              urls = [
                {
                  template = "https://www.google.com/search";
                  params = [
                    {
                      name = "udm";
                      value = "14";
                    }
                    {
                      name = "q";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
            };

            google-maps = {
              name = "Google Maps";
              iconMapObj."16" = "https://www.google.com/images/branding/product/ico/maps15_bnuw3a_16dp.ico";
              definedAliases = [ "gm" ];

              urls = [
                {
                  template = "https://www.google.com/maps";
                  params = [
                    {
                      name = "q";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
            };

            nix-packages = {
              name = "Nix Packages";
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "np" ];

              urls = [
                {
                  template = "https://search.nixos.org/packages";
                  params = [
                    {
                      name = "channel";
                      value = "unstable";
                    }
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
            };

            nixos-options = {
              name = "NixOS Options";
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "no" ];

              urls = [
                {
                  template = "https://search.nixos.org/options";
                  params = [
                    {
                      name = "channel";
                      value = "unstable";
                    }
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
            };

            home-manager-options = {
              name = "Home Manager Options";
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "ho" ];

              urls = [
                {
                  template = "https://home-manager-options.extranix.com";
                  params = [
                    {
                      name = "release";
                      value = "master";
                    }
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
            };

            youtube = {
              name = "YouTube";
              iconMapObj."16" = "https://www.youtube.com/favicon.ico";
              definedAliases = [ "y" ];

              urls = [
                {
                  template = "https://www.youtube.com/results";
                  params = [
                    {
                      name = "search_query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
            };

            bing.metaData.hidden = true;
            ddg.metaData.hidden = true;
            "ebay-ch".metaData.hidden = true;
            ecosia.metaData.hidden = true;
            google.metaData.hidden = true;
            perplexity.metaData.hidden = true;
            qwant.metaData.hidden = true;
            wikipedia.metaData.hidden = true;
          };
        };

        bookmarks = {
          force = true;

          settings = [
            {
              toolbar = true;
              bookmarks = [
                {
                  name = "Google";
                  url = "https://www.google.com";
                }
                {
                  name = "Gmail";
                  url = "https://mail.google.com/mail/u/0";
                }
                {
                  name = "YouTube";
                  url = "https://www.youtube.com";
                }
                {
                  # Check https://gogotaku.info for latest active domain
                  name = "Gogoanime";
                  url = "https://anitaku.io";
                }
                {
                  name = "TV Time";
                  url = "https://app.tvtime.com";
                }
                {
                  name = "Todoist";
                  url = "https://todoist.com/app?lang=en#start";
                }
                {
                  name = "reddit";
                  url = "https://www.reddit.com";
                }
                {
                  name = "Rechtschreibprüfung";
                  url = "https://mentor.duden.de/?utm_source=duden_de&utm_medium=premium_int&utm_campaign=topnavi&utm_content=duden-mentor-textpruefung";
                }
              ];
            }
          ];
        };

        userChrome = ''
          /* Multi-Account Containers */
          ${
            let
              colorMap = {
                blue = colors.normal.blue;
                green = colors.normal.green;
                # orange
                # pink
                purple = colors.normal.magenta;
                red = colors.normal.red;
                toolbar = colors.normal.gray;
                turquoise = colors.normal.cyan;
                yellow = colors.normal.yellow;
              };
            in
            lib.concatStringsSep "\n" (
              lib.mapAttrsToList (name: color: ''
                .identity-color-${name} {
                  --identity-tab-color: ${color} !important;
                  --identity-icon-color: ${color} !important;
                }
              '') colorMap
            )
          }
        '';

        settings = {
          "app.shield.optoutstudies.enabled" = false;
          "browser.aboutConfig.showWarning" = false;
          "browser.bookmarks.restore_default_bookmarks" = false;
          "browser.bookmarks.showMobileBookmarks" = false;
          "browser.contentblocking.category" = "standard";
          "browser.discovery.enabled" = false;
          "browser.download.autohideButton" = false;
          "browser.download.dir" = "${config.home.homeDirectory}/Downloads/Browser";
          "browser.download.folderList" = 2;
          "browser.laterrun.enabled" = false;
          "browser.link.open_newwindow.restriction" = 0;
          "browser.newtabpage.activity-stream.feeds.section.highlights" = false;
          "browser.newtabpage.activity-stream.feeds.snippets" = false;
          "browser.newtabpage.activity-stream.feeds.topsites" = false;
          "browser.newtabpage.activity-stream.showSearch" = false;
          "browser.newtabpage.enabled" = false;
          "browser.quitShortcut.disabled" = true;
          "browser.rights.3.shown" = true;
          "browser.search.region" = "CH";
          "browser.search.suggest.enabled.private" = true;
          "browser.startup.homepage" = lib.concatStringsSep "|" [
            "https://todoist.com/app/today"
            "https://mail.google.com/mail/u/0/#inbox"
          ];
          "browser.startup.page" = 1;
          "browser.tabs.groups.enabled" = false;
          "browser.tabs.warnOnClose" = false;
          "browser.toolbars.bookmarks.showOtherBookmarks" = false;
          "browser.toolbars.bookmarks.visibility" = "always";
          "browser.translations.automaticallyPopup" = false;
          "browser.uiCustomization.state" =
            let
              bitwarden = "_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action";
              export-tabs-urls-and-titles = "_17165bd9-9b71-4323-99a5-3d4ce49f3d75_-browser-action";
              grammarly = "87677a2c52b84ad3a151a4a72f5bd3c4_jetpack-browser-action";
              privacy-badger = "jid1-mnnxcxisbpnsxq_jetpack-browser-action";
              tab-session-manager = "tab-session-manager_sienori-browser-action";
              ublock-origin = "ublock0_raymondhill_net-browser-action";
              view-image = "_287dcf75-bec6-4eec-b4f6-71948a2eea29_-browser-action";
              wappalyzer = "wappalyzer_crunchlabz_com-browser-action";
            in
            {
              "placements" = {
                "widget-overflow-fixed-list" = [ ];
                "nav-bar" = [
                  "back-button"
                  "forward-button"
                  "stop-reload-button"
                  "home-button"
                  "urlbar-container"
                  "downloads-button"
                  bitwarden
                  privacy-badger
                  export-tabs-urls-and-titles
                  tab-session-manager
                  ublock-origin
                  wappalyzer
                ];
                "toolbar-menubar" = [ "menubar-items" ];
                "TabsToolbar" = [
                  "tabbrowser-tabs"
                  "new-tab-button"
                  "alltabs-button"
                ];
                "PersonalToolbar" = [ "personal-bookmarks" ];
              };
              "seen" = [
                bitwarden
                export-tabs-urls-and-titles
                grammarly
                privacy-badger
                tab-session-manager
                ublock-origin
                view-image
                wappalyzer

                "developer-button"
              ];
              "dirtyAreaCache" = [
                "nav-bar"
                "toolbar-menubar"
                "TabsToolbar"
                "PersonalToolbar"
              ];

              "currentVersion" = 18;
              "newElementCount" = 0;
            };
          "browser.urlbar.openViewOnFocus" = false;
          "browser.urlbar.placeholderName.private" = "Google";
          "browser.urlbar.placeholderName" = "Google";
          "browser.urlbar.showSearchSuggestionsFirst" = false;
          "browser.urlbar.suggest.openpage" = false;
          "devtools.aboutdebugging.collapsibilities.processes" = false;
          "devtools.accessibility.enabled" = false;
          "devtools.application.enabled" = false;
          "devtools.chrome.enabled" = true;
          "devtools.debugger.remote-enabled" = true;
          "devtools.memory.enabled" = false;
          "devtools.performance.enabled" = false;
          "devtools.performance.popup.intro-displayed" = true;
          "devtools.screenshot.audio.enabled" = false;
          "devtools.screenshot.clipboard.enabled" = true;
          "devtools.styleeditor.enabled" = false;
          "extensions.activeThemeID" = "default-theme@mozilla.org";
          "extensions.autoDisableScopes" = 0;
          "extensions.pocket.enabled" = false;
          "extensions.ui.extension.hidden" = false;
          "extensions.ui.locale.hidden" = true;
          "extensions.update.enabled" = false;
          "findbar.highlightAll" = true;
          "layout.spellcheckDefault" = 0;
          "media.eme.enabled" = true;
          "network.dns.disablePrefetch" = true;
          "network.predictor.enabled" = false;
          "network.prefetch-next" = false;
          "network.trr.mode" = 5;
          "pref.downloads.disable_button.edit_actions" = false;
          "privacy.donottrackheader.enabled" = true;
          "privacy.query_stripping.enabled" = true;
          "privacy.trackingprotection.enabled" = true;
          "privacy.userContext.enabled" = true;
          "privacy.userContext.extension" = "@contain-facebook";
          "privacy.userContext.ui.enabled" = true;
          "privacy.webrtc.hideGlobalIndicator" = true;
          "privacy.webrtc.legacyGlobalIndicator" = false;
          "services.sync.engine.addons" = false;
          "services.sync.engine.bookmarks" = true;
          "services.sync.engine.creditcards" = false;
          "services.sync.engine.history" = true;
          "services.sync.engine.passwords" = false;
          "services.sync.engine.prefs" = false;
          "services.sync.engine.tabs" = false;
          "signon.rememberSignons" = false;
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "toolkit.telemetry.reportingpolicy.firstRun" = false;
          "trailhead.firstrun.didSeeAboutWelcome" = true;
          "ui.textHighlightBackground" = colors.normal.accent;
          "ui.textHighlightForeground" = colors.normal.white;
          "ui.textSelectAttentionBackground" = colors.normal.green;
          "ui.textSelectAttentionForeground" = colors.normal.white;
          "ui.textSelectBackground" = colors.normal.blue;
          "ui.textSelectDisabledBackground" = colors.normal.gray;
          "ui.textSelectForeground" = colors.normal.white;
        };
      };
    };
  };
}
